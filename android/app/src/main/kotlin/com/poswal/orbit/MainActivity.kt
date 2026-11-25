package com.poswal.orbit

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channelName = "com.poswal.orbit/vault"
    private val pickRequestCode = 7001
    private var pendingPick: MethodChannel.Result? = null
    private val worker = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    // relative path -> document id. Avoids re-listing folders on every write.
    private val docIdCache = ConcurrentHashMap<String, String>()
    @Volatile private var cacheTree: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "pickTree" -> pickTree(result)
                        "hasPermission" -> {
                            val tree = call.argument<String>("treeUri")!!
                            val ok = contentResolver.persistedUriPermissions.any {
                                it.uri.toString() == tree && it.isReadPermission && it.isWritePermission
                            }
                            result.success(ok)
                        }
                        "releasePermission" -> {
                            val tree = Uri.parse(call.argument<String>("treeUri")!!)
                            try {
                                contentResolver.releasePersistableUriPermission(
                                    tree,
                                    Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                                )
                            } catch (e: Exception) {
                                // ignore: permission may already be gone
                            }
                            result.success(null)
                        }
                        "listAll" -> {
                            val tree = Uri.parse(call.argument<String>("treeUri")!!)
                            runAsync(result) { listAll(tree) }
                        }
                        "readText" -> {
                            val tree = Uri.parse(call.argument<String>("treeUri")!!)
                            val path = call.argument<String>("path")!!
                            runAsync(result) { readText(tree, path) }
                        }
                        "writeText" -> {
                            val tree = Uri.parse(call.argument<String>("treeUri")!!)
                            val path = call.argument<String>("path")!!
                            val content = call.argument<String>("content")!!
                            runAsync(result) { writeText(tree, path, content) }
                        }
                        "delete" -> {
                            val tree = Uri.parse(call.argument<String>("treeUri")!!)
                            val path = call.argument<String>("path")!!
                            runAsync(result) { delete(tree, path); null }
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("VAULT_ARGS", e.message, null)
                }
            }
    }

    // ------------------------------------------------------------ folder picker
    private fun pickTree(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("BUSY", "Folder picker is already open", null)
            return
        }
        pendingPick = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
            )
        }
        startActivityForResult(intent, pickRequestCode)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == pickRequestCode) {
            val callback = pendingPick
            pendingPick = null
            val uri = data?.data
            if (resultCode == Activity.RESULT_OK && uri != null) {
                try {
                    contentResolver.takePersistableUriPermission(
                        uri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    )
                    callback?.success(uri.toString())
                } catch (e: Exception) {
                    callback?.error("PERMISSION", e.message, null)
                }
            } else {
                callback?.success(null) // user cancelled
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    // -------------------------------------------------------------- threading
    private fun runAsync(result: MethodChannel.Result, block: () -> Any?) {
        worker.execute {
            try {
                val value = block()
                mainHandler.post { result.success(value) }
            } catch (e: Exception) {
                mainHandler.post { result.error("VAULT_IO", e.message ?: e.toString(), null) }
            }
        }
    }

    // ---------------------------------------------------------- SAF helpers
    private data class Child(
        val docId: String,
        val name: String,
        val isDir: Boolean,
        val size: Long,
        val modified: Long
    )

    private fun ensureCache(tree: Uri) {
        val key = tree.toString()
        if (cacheTree != key) {
            docIdCache.clear()
            cacheTree = key
        }
    }

    private fun rootDocId(tree: Uri): String = DocumentsContract.getTreeDocumentId(tree)

    private fun docUri(tree: Uri, docId: String): Uri =
        DocumentsContract.buildDocumentUriUsingTree(tree, docId)

    private fun queryChildren(tree: Uri, parentDocId: String): List<Child> {
        val out = ArrayList<Child>()
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED
        )
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(tree, parentDocId)
        contentResolver.query(childrenUri, columns, null, null, null)?.use { c ->
            while (c.moveToNext()) {
                out.add(
                    Child(
                        docId = c.getString(0),
                        name = c.getString(1) ?: "",
                        isDir = c.getString(2) == DocumentsContract.Document.MIME_TYPE_DIR,
                        size = if (c.isNull(3)) 0L else c.getLong(3),
                        modified = if (c.isNull(4)) 0L else c.getLong(4)
                    )
                )
            }
        }
        return out
    }

    /** Finds the document id of an existing file/folder, or null if it does not exist. */
    private fun resolveDocId(tree: Uri, path: String): String? {
        docIdCache[path]?.let { return it }
        var currentId = rootDocId(tree)
        var currentPath = ""
        for (segment in path.split("/").filter { it.isNotEmpty() }) {
            currentPath = if (currentPath.isEmpty()) segment else "$currentPath/$segment"
            val cached = docIdCache[currentPath]
            if (cached != null) {
                currentId = cached
                continue
            }
            val found = queryChildren(tree, currentId).firstOrNull { it.name == segment } ?: return null
            docIdCache[currentPath] = found.docId
            currentId = found.docId
        }
        return currentId
    }

    /** Creates the folder chain if needed and returns the last folder's document id. */
    private fun ensureDir(tree: Uri, dirPath: String): String {
        var currentId = rootDocId(tree)
        var currentPath = ""
        for (segment in dirPath.split("/").filter { it.isNotEmpty() }) {
            currentPath = if (currentPath.isEmpty()) segment else "$currentPath/$segment"
            val cached = docIdCache[currentPath]
            if (cached != null) {
                currentId = cached
                continue
            }
            val found = queryChildren(tree, currentId).firstOrNull { it.name == segment }
            currentId = if (found != null) {
                found.docId
            } else {
                val created = DocumentsContract.createDocument(
                    contentResolver,
                    docUri(tree, currentId),
                    DocumentsContract.Document.MIME_TYPE_DIR,
                    segment
                ) ?: throw IllegalStateException("Cannot create folder $currentPath")
                DocumentsContract.getDocumentId(created)
            }
            docIdCache[currentPath] = currentId
        }
        return currentId
    }

    // ---------------------------------------------------------- operations
    private fun listAll(tree: Uri): List<Map<String, Any>> {
        ensureCache(tree)
        docIdCache.clear()
        val out = ArrayList<Map<String, Any>>()

        fun walk(docId: String, prefix: String) {
            for (ch in queryChildren(tree, docId)) {
                val rel = if (prefix.isEmpty()) ch.name else "$prefix/${ch.name}"
                if (ch.isDir) {
                    // skip hidden folders such as .obsidian / .trash, but keep .orbit
                    if (ch.name.startsWith(".") && ch.name != ".orbit") continue
                    docIdCache[rel] = ch.docId
                    out.add(mapOf("path" to rel, "isDir" to true, "size" to 0L, "modified" to ch.modified))
                    walk(ch.docId, rel)
                } else {
                    docIdCache[rel] = ch.docId
                    out.add(mapOf("path" to rel, "isDir" to false, "size" to ch.size, "modified" to ch.modified))
                }
            }
        }
        walk(rootDocId(tree), "")
        return out
    }

    private fun readText(tree: Uri, path: String): String? {
        ensureCache(tree)
        val id = resolveDocId(tree, path) ?: return null
        val uri = docUri(tree, id)
        return try {
            contentResolver.openInputStream(uri)?.use { String(it.readBytes(), Charsets.UTF_8) }
        } catch (e: java.io.FileNotFoundException) {
            docIdCache.remove(path)
            null
        }
    }

    private fun fileUriForWrite(tree: Uri, path: String): Uri {
        var id = resolveDocId(tree, path)
        if (id == null) {
            val slash = path.lastIndexOf('/')
            val dir = if (slash >= 0) path.substring(0, slash) else ""
            val name = path.substring(slash + 1)
            val parentId = ensureDir(tree, dir)
            // "application/octet-stream" makes Android keep the exact file name
            // (it will not append .txt etc. to ".md").
            val created = DocumentsContract.createDocument(
                contentResolver,
                docUri(tree, parentId),
                "application/octet-stream",
                name
            ) ?: throw IllegalStateException("Cannot create $path")
            id = DocumentsContract.getDocumentId(created)
            docIdCache[path] = id
        }
        return docUri(tree, id!!)
    }

    private fun writeText(tree: Uri, path: String, content: String): Map<String, Any> {
        ensureCache(tree)
        val bytes = content.toByteArray(Charsets.UTF_8)
        var lastError: Exception? = null
        for (attempt in 0..1) {
            try {
                val uri = fileUriForWrite(tree, path)
                val stream = contentResolver.openOutputStream(uri, "wt")
                    ?: throw IllegalStateException("Cannot open $path for writing")
                stream.use { it.write(bytes) }

                var size = bytes.size.toLong()
                var modified = System.currentTimeMillis()
                val columns = arrayOf(
                    DocumentsContract.Document.COLUMN_SIZE,
                    DocumentsContract.Document.COLUMN_LAST_MODIFIED
                )
                contentResolver.query(uri, columns, null, null, null)?.use { c ->
                    if (c.moveToFirst()) {
                        if (!c.isNull(0)) size = c.getLong(0)
                        if (!c.isNull(1)) modified = c.getLong(1)
                    }
                }
                return mapOf("size" to size, "modified" to modified)
            } catch (e: Exception) {
                lastError = e
                docIdCache.remove(path) // cache may be stale, retry via slow path
            }
        }
        throw lastError ?: IllegalStateException("Write failed: $path")
    }

    private fun delete(tree: Uri, path: String) {
        ensureCache(tree)
        val id = resolveDocId(tree, path) ?: return
        try {
            DocumentsContract.deleteDocument(contentResolver, docUri(tree, id))
        } catch (e: java.io.FileNotFoundException) {
            // already gone
        }
        docIdCache.remove(path)
        docIdCache.keys.filter { it.startsWith("$path/") }.forEach { docIdCache.remove(it) }
    }
}
