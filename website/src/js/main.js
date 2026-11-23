/**
 * Poswal Orbit · Main Client Module
 * Vanilla ES module. Zero external dependencies. Strict CSP compliant.
 */

(function () {
  'use strict';

  // --- 1. Theme Management ---
  const THEME_KEY = 'orbit_theme_preference';
  const root = document.documentElement;

  function getPreferredTheme() {
    try {
      const urlParams = new URLSearchParams(window.location.search);
      const queryTheme = urlParams.get('theme');
      if (queryTheme && ['dark', 'light', 'oled'].includes(queryTheme)) {
        return queryTheme;
      }
      const stored = localStorage.getItem(THEME_KEY);
      if (stored && ['dark', 'light', 'oled'].includes(stored)) {
        return stored;
      }
    } catch (_) {
      // Ignore localStorage access restrictions
    }
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
  }

  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
    try {
      localStorage.setItem(THEME_KEY, theme);
    } catch (_) {}

    document.querySelectorAll('.theme-btn').forEach(btn => {
      const isActive = btn.getAttribute('data-theme-val') === theme;
      btn.classList.toggle('active', isActive);
      btn.setAttribute('aria-pressed', isActive ? 'true' : 'false');
    });
  }

  const initialTheme = getPreferredTheme();
  applyTheme(initialTheme);

  document.querySelectorAll('.theme-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const val = btn.getAttribute('data-theme-val');
      if (val) applyTheme(val);
    });
  });

  // --- 2. 3D Parallax Scene ---
  const sceneWrapper = document.querySelector('.scene-wrapper');
  const heroScene = document.querySelector('.hero-scene');
  const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

  if (heroScene && sceneWrapper && !prefersReducedMotion.matches) {
    let ticking = false;
    let targetX = 0;
    let targetY = 0;
    const isRtl = root.getAttribute('dir') === 'rtl';

    function updateTilt() {
      const baseRotY = isRtl ? 12 : -12;
      const baseRotX = 8;
      const rotY = baseRotY + targetX * 10;
      const rotX = baseRotX - targetY * 10;
      sceneWrapper.style.transform = `rotateY(${rotY}deg) rotateX(${rotX}deg)`;
      ticking = false;
    }

    heroScene.addEventListener('pointermove', (e) => {
      if (document.hidden) return;
      const rect = heroScene.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width - 0.5;
      const y = (e.clientY - rect.top) / rect.height - 0.5;
      targetX = x;
      targetY = y;

      if (!ticking) {
        requestAnimationFrame(updateTilt);
        ticking = true;
      }
    });

    heroScene.addEventListener('pointerleave', () => {
      targetX = 0;
      targetY = 0;
      if (!ticking) {
        requestAnimationFrame(updateTilt);
        ticking = true;
      }
    });
  }

  // --- 3. Simulator: Tab Switcher ---
  const tabBtns = document.querySelectorAll('.sim-tab-btn');
  const panels = document.querySelectorAll('.sim-panel');

  tabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');
      tabBtns.forEach(b => {
        const active = b === btn;
        b.classList.toggle('active', active);
        b.setAttribute('aria-selected', active ? 'true' : 'false');
      });
      panels.forEach(p => {
        p.classList.toggle('active', p.id === target);
      });
    });
  });

  // --- 4. Simulator: Habit Check-in & Ring ---
  const habitItems = document.querySelectorAll('.habit-check-item');
  const ringFill = document.querySelector('.sim-ring-fill');
  const ringScore = document.querySelector('.ring-score');
  const liveStatus = document.getElementById('sim-live-status');

  function updateHabitProgress() {
    const total = habitItems.length;
    const completed = document.querySelectorAll('.habit-check-item.completed').length;
    const percent = Math.round((completed / total) * 100);

    if (ringScore) {
      ringScore.textContent = `${percent}%`;
    }

    if (ringFill) {
      const circumference = 440;
      const offset = circumference - (percent / 100) * circumference;
      ringFill.style.strokeDashoffset = offset;
    }

    if (liveStatus) {
      liveStatus.textContent = `Completed ${completed} of ${total} habits. Score ${percent} percent.`;
    }
  }

  habitItems.forEach(item => {
    item.addEventListener('click', () => {
      item.classList.toggle('completed');
      const isChecked = item.classList.contains('completed');
      item.setAttribute('aria-checked', isChecked ? 'true' : 'false');
      updateHabitProgress();
    });

    item.addEventListener('keydown', (e) => {
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        item.click();
      }
    });
  });

  // --- 5. Simulator: Task Natural Language Parser ---
  const taskInput = document.getElementById('task-input');
  const chipDue = document.getElementById('chip-due');
  const chipPriority = document.getElementById('chip-priority');
  const chipProject = document.getElementById('chip-project');
  const sampleChips = document.querySelectorAll('.sample-chip');

  function parseTask(text) {
    if (!text || !text.trim()) {
      return { due: 'None', priority: 'Normal', project: 'None' };
    }

    let due = 'Today';
    let priority = 'Normal';
    let project = 'Inbox';

    // Due date detection
    if (/tomorrow/i.test(text) || /कल/i.test(text)) {
      due = 'Tomorrow';
    } else if (/friday/i.test(text) || /शुक्रवार/i.test(text) || /جمعہ/i.test(text)) {
      due = 'Friday';
    } else if (/today/i.test(text) || /आज/i.test(text) || /آج/i.test(text)) {
      due = 'Today';
    }

    const timeMatch = text.match(/(\d{1,2}(?::\d{2})?\s*(?:am|pm))/i) || text.match(/(\d{1,2}\s*बजे)/i) || text.match(/(\d{1,2}\s*بجے)/i);
    if (timeMatch) {
      due += ` ${timeMatch[1]}`;
    }

    // Priority detection
    if (/priority\s*high/i.test(text) || /!high/i.test(text) || /urgent/i.test(text) || /p1/i.test(text) || /उच्च/i.test(text) || /اعلی/i.test(text)) {
      priority = 'High';
    } else if (/priority\s*low/i.test(text) || /!low/i.test(text) || /p3/i.test(text) || /निम्न/i.test(text) || /کم/i.test(text)) {
      priority = 'Low';
    }

    // Tag / project hashtag detection
    const tagMatch = text.match(/#([\w\u0900-\u097F\u0600-\u06FF]+)/);
    if (tagMatch) {
      project = `#${tagMatch[1]}`;
    }

    return { due, priority, project };
  }

  function handleTaskInput() {
    if (!taskInput) return;
    const res = parseTask(taskInput.value);
    if (chipDue) chipDue.textContent = res.due;
    if (chipPriority) chipPriority.textContent = res.priority;
    if (chipProject) chipProject.textContent = res.project;
  }

  if (taskInput) {
    taskInput.addEventListener('input', handleTaskInput);
  }

  sampleChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const sampleText = chip.getAttribute('data-sample') || chip.textContent.trim();
      if (taskInput) {
        taskInput.value = sampleText;
        handleTaskInput();
        taskInput.focus();
      }
    });
  });

  // --- 6. Design Section: Glass Slider ---
  const glassSlider = document.getElementById('glass-slider');
  const sampleGlassCard = document.getElementById('sample-glass-card');
  const glassBlurValue = document.getElementById('glass-blur-value');

  if (glassSlider && sampleGlassCard) {
    glassSlider.addEventListener('input', (e) => {
      const val = e.target.value;
      sampleGlassCard.style.backdropFilter = `blur(${val}px)`;
      sampleGlassCard.style.webkitBackdropFilter = `blur(${val}px)`;
      if (glassBlurValue) glassBlurValue.textContent = `${val}px`;
    });
  }

  // --- 7. Checksum Copy Button ---
  const copyBtn = document.getElementById('copy-sha-btn');
  const checksumText = document.getElementById('sha-checksum-text');
  const copyNotification = document.getElementById('copy-status');

  if (copyBtn && checksumText) {
    copyBtn.addEventListener('click', async () => {
      const text = checksumText.textContent.trim();
      try {
        await navigator.clipboard.writeText(text);
        const originalText = copyBtn.textContent;
        const copiedLabel = copyBtn.getAttribute('data-copied-label') || 'Copied';
        copyBtn.textContent = copiedLabel;
        if (copyNotification) copyNotification.textContent = copiedLabel;

        setTimeout(() => {
          copyBtn.textContent = originalText;
          if (copyNotification) copyNotification.textContent = '';
        }, 2000);
      } catch (_) {
        // Fallback if clipboard API is blocked
      }
    });
  }
})();
