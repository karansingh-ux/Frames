import {
  createIcons,
  Layers,
  Camera,
  Clipboard,
  Download,
  Check,
  Star,
  ShieldCheck,
  Sparkles,
  Cpu,
  Apple,
  Github,
  ArrowDownRight,
  XCircle,
  X,
  CheckCircle2,
  Clock,
  Scroll,
  MessageSquare,
  Lock,
  Database,
  CloudOff,
  Shield,
  ChevronDown,
  Wifi,
  BatteryCharging,
  AlertTriangle,
  Info,
  ClipboardCheck,
  Settings,
  Command,
  Heart,
  Folder,
  Mail,
  Coffee
} from 'lucide';

// Initialize Selected Lucide Icons for optimal performance
function initIcons() {
  createIcons({
    icons: {
      Layers,
      Camera,
      Clipboard,
      Download,
      Check,
      Star,
      ShieldCheck,
      Sparkles,
      Cpu,
      Apple,
      Github,
      ArrowDownRight,
      XCircle,
      X,
      CheckCircle2,
      Clock,
      Scroll,
      MessageSquare,
      Lock,
      Database,
      CloudOff,
      Shield,
      ChevronDown,
      Wifi,
      BatteryCharging,
      AlertTriangle,
      Info,
      ClipboardCheck,
      Settings,
      Command,
      Heart,
      Folder,
      Mail,
      Coffee
    }
  });
}

// 60-Second Timer Engine for Hero Preview
let timerDuration = 60;
let remainingTime = 60;
let timerInterval: number | null = null;
const circumference = 2 * Math.PI * 14; // r = 14

function startTimer() {
  if (timerInterval) clearInterval(timerInterval);
  remainingTime = timerDuration;
  updateTimerUI();

  timerInterval = window.setInterval(() => {
    remainingTime -= 1;
    if (remainingTime <= 0) {
      remainingTime = timerDuration;
      showToast('Auto-Saved to ~/Desktop after 60s', 'info');
    }
    updateTimerUI();
  }, 1000);
}

function updateTimerUI() {
  const timerText = document.getElementById('timer-count');
  const timerCircle = document.getElementById('timer-progress') as SVGCircleElement | null;
  
  if (timerText) {
    timerText.textContent = `${remainingTime}s`;
  }
  
  if (timerCircle) {
    const offset = circumference - (remainingTime / timerDuration) * circumference;
    timerCircle.style.strokeDashoffset = `${offset}`;
  }
}

// Toast Notification System
function showToast(message: string, type: 'success' | 'info' | 'warning' = 'success') {
  const container = document.getElementById('toast-container');
  if (!container) return;

  const toast = document.createElement('div');
  const bgClass = type === 'success' ? 'border-emerald-500/40 bg-emerald-950/90 text-emerald-200' :
                  type === 'warning' ? 'border-amber-500/40 bg-amber-950/90 text-amber-200' :
                  'border-brand-electric/40 bg-[#000031]/95 text-blue-200';

  toast.className = `flex items-center gap-3 px-4 py-3 rounded-xl border backdrop-blur-xl shadow-2xl transition-all duration-300 transform translate-y-4 opacity-0 pointer-events-auto ${bgClass}`;
  
  let iconName = type === 'success' ? 'check-circle-2' : type === 'warning' ? 'alert-triangle' : 'info';
  
  toast.innerHTML = `
    <i data-lucide="${iconName}" class="w-4 h-4 shrink-0"></i>
    <span class="text-sm font-medium">${message}</span>
  `;

  container.appendChild(toast);
  initIcons();

  // Animate in
  requestAnimationFrame(() => {
    toast.classList.remove('translate-y-4', 'opacity-0');
  });

  // Remove after 3.5s
  setTimeout(() => {
    toast.classList.add('opacity-0', 'translate-y-2');
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

// Stack Actions Setup
function initStackInteractions() {
  // Copy Action
  const copyBtn = document.getElementById('action-copy-btn');
  if (copyBtn) {
    copyBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      showToast('Copied to Clipboard! (0 disk files written)', 'success');
      startTimer(); // reset
    });
  }

  // Save Action
  const saveBtn = document.getElementById('action-save-btn');
  if (saveBtn) {
    saveBtn.addEventListener('click', (e) => {
      e.stopPropagation();
      showToast('Saved to ~/Desktop', 'info');
      startTimer(); // reset
    });
  }
}

// Settings Window Tab Navigation (Matching native app tabs)
function initSettingsTabs() {
  const tabButtons = document.querySelectorAll('.settings-tab-btn');
  const tabPanels = document.querySelectorAll('.settings-tab-panel');

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.getAttribute('data-tab');

      // Update button styles
      tabButtons.forEach(b => {
        b.classList.remove('bg-[#0302FF]', 'border-[#5B5AFF]/40', 'text-white');
        b.classList.add('bg-white/[0.04]', 'border-white/[0.04]', 'text-slate-400');
      });
      btn.classList.add('bg-[#0302FF]', 'border-[#5B5AFF]/40', 'text-white');
      btn.classList.remove('bg-white/[0.04]', 'border-white/[0.04]', 'text-slate-400');

      // Update panels
      tabPanels.forEach(panel => {
        if (panel.id === `tab-${target}`) {
          panel.classList.remove('hidden');
        } else {
          panel.classList.add('hidden');
        }
      });
    });
  });
}

// FAQ Accordion
function initFAQ() {
  const faqItems = document.querySelectorAll('.faq-item');

  faqItems.forEach(item => {
    const questionBtn = item.querySelector('.faq-trigger');
    const answer = item.querySelector('.faq-answer');
    const icon = item.querySelector('.faq-icon');

    if (questionBtn && answer && icon) {
      questionBtn.addEventListener('click', () => {
        const isOpen = !answer.classList.contains('hidden');

        // Close all others
        faqItems.forEach(other => {
          other.querySelector('.faq-answer')?.classList.add('hidden');
          const otherIcon = other.querySelector('.faq-icon');
          if (otherIcon) otherIcon.classList.remove('rotate-180');
        });

        if (!isOpen) {
          answer.classList.remove('hidden');
          icon.classList.add('rotate-180');
        }
      });
    }
  });
}

// Global Document Initialization
document.addEventListener('DOMContentLoaded', () => {
  initIcons();
  startTimer();
  initStackInteractions();
  initSettingsTabs();
  initFAQ();
});
