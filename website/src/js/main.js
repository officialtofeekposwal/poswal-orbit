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

  // --- 8. Interactive Device Chamber: iPhone 16 Pro Screen Controller ---
  const screenTabBtns = document.querySelectorAll('.screen-tab-btn');
  const iphoneTabItems = document.querySelectorAll('.iphone-tab-item');
  const deviceScreens = document.querySelectorAll('.device-screen');

  function switchDeviceScreen(targetScreenId) {
    if (!targetScreenId) return;
    const cleanId = targetScreenId.startsWith('screen-') ? targetScreenId : `screen-${targetScreenId}`;

    // Update external screen tabs
    screenTabBtns.forEach(b => {
      const isMatch = b.getAttribute('data-screen') === targetScreenId || b.getAttribute('data-screen') === cleanId;
      b.classList.toggle('active', isMatch);
      b.setAttribute('aria-selected', isMatch ? 'true' : 'false');
    });

    // Update internal iPhone tabs
    iphoneTabItems.forEach(b => {
      const isMatch = b.getAttribute('data-screen') === targetScreenId || b.getAttribute('data-screen') === cleanId;
      b.classList.toggle('active', isMatch);
      b.setAttribute('aria-selected', isMatch ? 'true' : 'false');
    });

    // Animate active device screen
    deviceScreens.forEach(s => {
      const isTarget = s.id === cleanId;
      s.classList.toggle('active', isTarget);
    });
  }

  screenTabBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      switchDeviceScreen(btn.getAttribute('data-screen'));
    });
  });

  iphoneTabItems.forEach(btn => {
    btn.addEventListener('click', () => {
      switchDeviceScreen(btn.getAttribute('data-screen'));
    });
  });

  // Device Today: Interactive Tasks & Progress Ring
  const deviceTaskItems = document.querySelectorAll('.device-checklist-item');
  const deviceRingIndicator = document.getElementById('device-ring-indicator');
  const deviceRingScore = document.getElementById('device-ring-score');
  const deviceHabitsStat = document.getElementById('device-habits-stat');

  function updateDeviceRing() {
    if (!deviceTaskItems.length) return;
    const total = deviceTaskItems.length;
    const completed = document.querySelectorAll('.device-checklist-item.completed').length;
    const percent = Math.round((completed / total) * 100);

    if (deviceRingScore) {
      deviceRingScore.textContent = `${percent}%`;
    }
    if (deviceHabitsStat) {
      deviceHabitsStat.textContent = `${completed} of ${total} Habits Done`;
    }
    if (deviceRingIndicator) {
      const circumference = 238.76;
      const offset = circumference - (percent / 100) * circumference;
      deviceRingIndicator.style.strokeDashoffset = offset;
    }
  }

  deviceTaskItems.forEach(item => {
    item.addEventListener('click', () => {
      const isChecked = item.classList.toggle('completed');
      item.setAttribute('aria-checked', isChecked ? 'true' : 'false');
      const checkGlyph = item.querySelector('.device-checkbox-glyph');
      if (checkGlyph) {
        checkGlyph.textContent = isChecked ? '✓' : '';
      }
      updateDeviceRing();
    });

    item.addEventListener('keydown', (e) => {
      if (e.key === ' ' || e.key === 'Enter') {
        e.preventDefault();
        item.click();
      }
    });
  });

  // Device Habits: 7-Day Heatmap & Toggles
  const deviceHeatToday = document.getElementById('device-heat-today');
  if (deviceHeatToday) {
    deviceHeatToday.addEventListener('click', () => {
      deviceHeatToday.classList.toggle('filled');
    });
  }

  const deviceTogglePills = document.querySelectorAll('.device-toggle-pill');
  deviceTogglePills.forEach(pill => {
    pill.addEventListener('click', () => {
      const isActive = pill.classList.toggle('active');
      pill.textContent = isActive ? '✓' : '';
    });
  });

  // Device Tasks: Natural Language Parser
  const deviceNlpInput = document.getElementById('device-nlp-input');
  const deviceParsedTags = document.getElementById('device-parsed-tags');
  const deviceSuggestionChips = document.querySelectorAll('.device-suggestion-chip');

  function updateDeviceNlp(text) {
    if (!deviceParsedTags) return;
    if (!text || !text.trim()) {
      deviceParsedTags.innerHTML = '<span class="parsed-pill pill-duration">Inbox</span>';
      return;
    }

    const tags = [];
    if (/every\s*day|daily/i.test(text)) {
      tags.push('<span class="parsed-pill pill-habit">Repeat: Daily</span>');
    } else if (/friday/i.test(text)) {
      tags.push('<span class="parsed-pill pill-habit">Due: Friday</span>');
    } else if (/tomorrow/i.test(text)) {
      tags.push('<span class="parsed-pill pill-habit">Due: Tomorrow</span>');
    }

    const time = text.match(/(\d{1,2}(?::\d{2})?\s*(?:am|pm))/i);
    if (time) {
      tags.push(`<span class="parsed-pill pill-time">Time: ${time[1]}</span>`);
    }

    if (/mins|minutes|pages/i.test(text)) {
      const dur = text.match(/(\d+\s*(?:mins|minutes|pages))/i);
      if (dur) {
        tags.push(`<span class="parsed-pill pill-duration">${dur[1]}</span>`);
      }
    }

    if (/priority\s*high|!high|p1/i.test(text)) {
      tags.push('<span class="parsed-pill pill-habit">Priority: High</span>');
    }

    const hash = text.match(/#([\w\u0900-\u097F\u0600-\u06FF]+)/);
    if (hash) {
      tags.push(`<span class="parsed-pill pill-time">#${hash[1]}</span>`);
    }

    deviceParsedTags.innerHTML = tags.length ? tags.join('') : '<span class="parsed-pill pill-duration">Task Parsed</span>';
  }

  if (deviceNlpInput) {
    deviceNlpInput.addEventListener('input', (e) => {
      updateDeviceNlp(e.target.value);
    });
  }

  deviceSuggestionChips.forEach(chip => {
    chip.addEventListener('click', () => {
      const sample = chip.getAttribute('data-nlp') || chip.textContent.trim();
      if (deviceNlpInput) {
        deviceNlpInput.value = sample;
        updateDeviceNlp(sample);
      }
    });
  });

  // Device Notes: Markdown Tools
  const deviceToolBtns = document.querySelectorAll('.device-tool-btn');
  deviceToolBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      btn.classList.toggle('active');
    });
  });

  // --- 9. Mobile Navigation Drawer ---
  const mobileMenuBtn = document.getElementById('mobile-menu-btn');
  const mobileNav = document.getElementById('mobile-nav');

  if (mobileMenuBtn && mobileNav) {
    mobileMenuBtn.addEventListener('click', () => {
      const isOpen = mobileNav.classList.toggle('is-open');
      mobileMenuBtn.classList.toggle('active', isOpen);
      mobileMenuBtn.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
      mobileNav.setAttribute('aria-hidden', isOpen ? 'false' : 'true');
    });

    mobileNav.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', () => {
        mobileNav.classList.remove('is-open');
        mobileMenuBtn.classList.remove('active');
        mobileMenuBtn.setAttribute('aria-expanded', 'false');
        mobileNav.setAttribute('aria-hidden', 'true');
      });
    });
  }

  // --- 10. Device Orientation Permission & Gyro Parallax ---
  const gyroBtn = document.getElementById('gyro-btn');

  function handleOrientation(e) {
    if (document.hidden || !sceneWrapper || prefersReducedMotion.matches) return;
    const gamma = e.gamma || 0; // Left to right [-90, 90]
    const beta = e.beta || 0;   // Front to back [-180, 180]
    const clampX = Math.max(-25, Math.min(25, gamma)) / 25;
    const clampY = Math.max(-25, Math.min(25, beta - 45)) / 25;
    const baseRotY = root.getAttribute('dir') === 'rtl' ? 12 : -12;
    const rotY = baseRotY + clampX * 12;
    const rotX = 8 - clampY * 12;
    sceneWrapper.style.transform = `rotateY(${rotY}deg) rotateX(${rotX}deg)`;
  }

  if (window.DeviceOrientationEvent) {
    if (typeof DeviceOrientationEvent.requestPermission === 'function') {
      // iOS 13+ requires user interaction to grant permission
      if (gyroBtn) {
        gyroBtn.style.display = 'inline-flex';
        gyroBtn.addEventListener('click', async () => {
          try {
            const permission = await DeviceOrientationEvent.requestPermission();
            if (permission === 'granted') {
              window.addEventListener('deviceorientation', handleOrientation);
              gyroBtn.style.display = 'none';
            }
          } catch (_) {}
        });
      }
    } else {
      // Non-iOS devices supporting orientation
      window.addEventListener('deviceorientation', handleOrientation);
    }
  }
})();
