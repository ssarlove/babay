/**
 * Baby Care Web Application
 * Emotion detection and history management
 */

// ========================================
// Configuration
// ========================================
const CONFIG = {
  STORAGE_KEY: 'baby_care_history',
  SETTINGS_KEY: 'baby_care_settings',
  EMOTION_LABELS: ['happy', 'crying', 'neutral', 'tired', 'laughing', 'sad', 'angry'],
  DEMO_MODE: true, // Set to true if TF.js model isn't loaded
};

// ========================================
// Emotion Data
// ========================================
const EMOTION_DATA = {
  happy: {
    emoji: '😊',
    color: '#10B981',
    name: 'Happy',
    description: 'Your baby is content and in a great mood!',
    suggestions: [
      { icon: '🍼', text: 'Engage in tummy time for development', category: 'development' },
      { icon: '🎵', text: 'Play peek-a-boo for social bonding', category: 'play' },
      { icon: '🧸', text: 'Talk and sing to your baby', category: 'bonding' },
    ]
  },
  crying: {
    emoji: '😢',
    color: '#F59E0B',
    name: 'Needs Attention',
    description: 'Your baby may need comfort, feeding, or has a specific need.',
    suggestions: [
      { icon: '🧷', text: 'Check if diaper needs changing', category: 'basic_care' },
      { icon: '🍼', text: 'Offer a feeding - baby may be hungry', category: 'feeding' },
      { icon: '🤱', text: 'Try burping - baby might have gas', category: 'comfort' },
      { icon: '🌡️', text: 'Check temperature - baby might be too hot or cold', category: 'basic_care' },
    ]
  },
  neutral: {
    emoji: '😌',
    color: '#3B82F6',
    name: 'Calm',
    description: 'Your baby is calm and observing their surroundings.',
    suggestions: [
      { icon: '💬', text: 'Talk and sing to baby', category: 'bonding' },
      { icon: '🧸', text: 'Engage with age-appropriate toys', category: 'play' },
      { icon: '🚶', text: 'Take for a walk outside for fresh air', category: 'stimulation' },
    ]
  },
  tired: {
    emoji: '😴',
    color: '#8B5CF6',
    name: 'Tired',
    description: 'Your baby might be ready for a nap soon.',
    suggestions: [
      { icon: '🌙', text: 'Begin wind-down routine now', category: 'sleep' },
      { icon: '💡', text: 'Dim lights and reduce stimulation', category: 'sleep' },
      { icon: '🧸', text: 'Offer pacifier if you use one', category: 'comfort' },
    ]
  },
  laughing: {
    emoji: '😄',
    color: '#10B981',
    name: 'Laughing',
    description: 'Your baby is joyful and playful!',
    suggestions: [
      { icon: '🎉', text: 'Play gentle tickle games', category: 'play' },
      { icon: '😜', text: 'Make silly faces and funny sounds', category: 'play' },
      { icon: '🎵', text: 'Dance and move rhythmically with baby', category: 'play' },
    ]
  },
  sad: {
    emoji: '😢',
    color: '#F59E0B',
    name: 'Sad',
    description: 'Your baby seems a bit down or uncomfortable.',
    suggestions: [
      { icon: '🤗', text: 'Give extra cuddles and comfort', category: 'comfort' },
      { icon: '🧸', text: 'Check for any discomfort or irritation', category: 'basic_care' },
      { icon: '🎵', text: 'Try soothing music or white noise', category: 'comfort' },
    ]
  },
  angry: {
    emoji: '😠',
    color: '#EF4444',
    name: 'Frustrated',
    description: 'Your baby seems frustrated or upset.',
    suggestions: [
      { icon: '🍼', text: 'Check if baby is hungry', category: 'feeding' },
      { icon: '💤', text: 'Check if baby needs sleep', category: 'sleep' },
      { icon: '🤫', text: 'Try shushing and gentle rocking', category: 'comfort' },
    ]
  }
};

// ========================================
// App State
// ========================================
const state = {
  camera: null,
  stream: null,
  model: null,
  isScanning: false,
  settings: {
    autoSave: true,
    showConfidence: true,
    soundEffects: true
  }
};

// ========================================
// DOM Elements
// ========================================
const elements = {
  cameraContainer: document.getElementById('camera-container'),
  cameraFeed: document.getElementById('camera-feed'),
  faceOverlay: document.getElementById('face-overlay'),
  faceGuide: document.getElementById('face-guide'),
  scanBtn: document.getElementById('scan-btn'),
  historyBtn: document.getElementById('history-btn'),
  settingsBtn: document.getElementById('settings-btn'),
  scanningIndicator: document.getElementById('scanning-indicator'),
  resultOverlay: document.getElementById('result-overlay'),
  historyPanel: document.getElementById('history-panel'),
  settingsPanel: document.getElementById('settings-panel'),
  loadingScreen: document.getElementById('loading-screen'),
  errorScreen: document.getElementById('error-screen'),
  historyList: document.getElementById('history-list'),
  clearHistoryBtn: document.getElementById('clear-history'),
  timeDisplay: document.getElementById('time-display'),
};

// ========================================
// Initialization
// ========================================
async function init() {
  loadSettings();
  updateTime();
  setInterval(updateTime, 1000);
  
  // Load history
  renderHistory();
  
  // Event listeners
  elements.scanBtn.addEventListener('click', captureAndAnalyze);
  elements.historyBtn.addEventListener('click', () => showPanel('history'));
  elements.settingsBtn.addEventListener('click', () => showPanel('settings'));
  document.getElementById('close-result').addEventListener('click', closeResult);
  document.getElementById('close-history').addEventListener('click', () => hidePanel('history'));
  document.getElementById('close-settings').addEventListener('click', () => hidePanel('settings'));
  document.getElementById('scan-again-btn').addEventListener('click', closeResult);
  elements.clearHistoryBtn.addEventListener('click', clearHistory);
  document.getElementById('retry-btn').addEventListener('click', initCamera);
  
  // Settings toggles
  document.getElementById('auto-save').addEventListener('change', (e) => {
    state.settings.autoSave = e.target.checked;
    saveSettings();
  });
  document.getElementById('show-confidence').addEventListener('change', (e) => {
    state.settings.showConfidence = e.target.checked;
    saveSettings();
  });
  document.getElementById('sound-effects').addEventListener('change', (e) => {
    state.settings.soundEffects = e.target.checked;
    saveSettings();
  });
  
  // Initialize camera
  await initCamera();
  
  // Load ML model (optional - will use demo mode if unavailable)
  await loadModel();
}

async function initCamera() {
  try {
    elements.errorScreen.classList.add('hidden');
    
    // Check for camera support
    if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
      throw new Error('Camera not supported in this browser');
    }
    
    const stream = await navigator.mediaDevices.getUserMedia({
      video: {
        facingMode: 'user',
        width: { ideal: 1280 },
        height: { ideal: 720 }
      },
      audio: false
    });
    
    elements.cameraFeed.srcObject = stream;
    await elements.cameraFeed.play();
    state.stream = stream;
    
    // Hide loading, show camera
    elements.loadingScreen.classList.add('hidden');
    elements.cameraContainer.classList.remove('hidden');
    
    // Draw face guide animation
    animateFaceGuide();
    
  } catch (error) {
    console.error('Camera error:', error);
    elements.loadingScreen.classList.add('hidden');
    elements.errorScreen.classList.remove('hidden');
  }
}

async function loadModel() {
  try {
    // Try to load TensorFlow.js face detection model
    if (!CONFIG.DEMO_MODE) {
      state.model = await blazeface.load();
      console.log('Face detection model loaded');
    }
  } catch (error) {
    console.log('Using demo mode for emotion detection');
    state.model = null;
  }
}

// ========================================
// Camera & Detection
// ========================================
async function captureAndAnalyze() {
  if (state.isScanning) return;
  
  state.isScanning = true;
  elements.scanningIndicator.classList.remove('hidden');
  elements.scanBtn.style.opacity = '0.5';
  
  // Capture frame from video
  const canvas = document.createElement('canvas');
  canvas.width = elements.cameraFeed.videoWidth;
  canvas.height = elements.cameraFeed.videoHeight;
  const ctx = canvas.getContext('2d');
  
  // Mirror the image
  ctx.translate(canvas.width, 0);
  ctx.scale(-1, 1);
  ctx.drawImage(elements.cameraFeed, 0, 0);
  
  try {
    // Detect emotions
    const result = await detectEmotion(canvas);
    
    // Show result
    showResult(result);
    
    // Save to history if auto-save enabled
    if (state.settings.autoSave) {
      saveToHistory(result);
    }
    
  } catch (error) {
    console.error('Detection error:', error);
    // Show demo result on error
    const demoResult = getDemoResult();
    showResult(demoResult);
    if (state.settings.autoSave) {
      saveToHistory(demoResult);
    }
  }
  
  state.isScanning = false;
  elements.scanningIndicator.classList.add('hidden');
  elements.scanBtn.style.opacity = '1';
}

async function detectEmotion(imageSource) {
  // If model is loaded, use it
  if (state.model) {
    const predictions = await state.model.estimateFaces(imageSource, false);
    
    if (predictions.length === 0) {
      return {
        emotion: 'neutral',
        confidence: 0.5,
        message: 'No face detected. Please try again.'
      };
    }
    
    // For demo, we'll use a simple heuristic based on image analysis
    // In production, you'd use the emotion classification model here
    return analyzeDetectedFace(predictions[0]);
  }
  
  // Demo mode - simulate detection
  return getDemoResult();
}

function analyzeDetectedFace(prediction) {
  // This would connect to your emotion classification model
  // For demo, we return a random positive emotion
  const emotions = ['happy', 'laughing', 'neutral'];
  const emotion = emotions[Math.floor(Math.random() * emotions.length)];
  const confidence = 0.7 + Math.random() * 0.25;
  
  return {
    emotion: emotion,
    confidence: confidence,
    message: `Detected ${emotion} expression`
  };
}

function getDemoResult() {
  // Return varied results for demo purposes
  const emotions = ['happy', 'crying', 'neutral', 'tired', 'laughing'];
  const weights = [0.35, 0.25, 0.2, 0.1, 0.1];
  
  let random = Math.random();
  let cumulative = 0;
  let emotion = 'neutral';
  
  for (let i = 0; i < emotions.length; i++) {
    cumulative += weights[i];
    if (random < cumulative) {
      emotion = emotions[i];
      break;
    }
  }
  
  return {
    emotion: emotion,
    confidence: 0.75 + Math.random() * 0.2,
    message: `Detected ${emotion} expression (demo mode)`
  };
}

// ========================================
// UI Functions
// ========================================
function showResult(result) {
  const emotionData = EMOTION_DATA[result.emotion] || EMOTION_DATA.neutral;
  
  // Update result card
  document.getElementById('emotion-icon').textContent = emotionData.emoji;
  document.getElementById('emotion-name').textContent = emotionData.name;
  document.getElementById('emotion-description').textContent = emotionData.description;
  
  // Update confidence bar
  const confidencePercent = Math.round(result.confidence * 100);
  document.getElementById('confidence-fill').style.width = `${confidencePercent}%`;
  document.getElementById('confidence-text').textContent = `${confidencePercent}% confidence`;
  
  // Update suggestions
  const suggestionsList = document.getElementById('suggestions-list');
  suggestionsList.innerHTML = '';
  
  emotionData.suggestions.forEach(suggestion => {
    const item = document.createElement('div');
    item.className = 'suggestion-item';
    item.innerHTML = `
      <div class="suggestion-icon" style="background: ${emotionData.color}20; color: ${emotionData.color}">
        ${suggestion.icon}
      </div>
      <div class="suggestion-text">${suggestion.text}</div>
    `;
    suggestionsList.appendChild(item);
  });
  
  // Show overlay
  elements.resultOverlay.classList.remove('hidden');
  
  // Play sound if enabled
  if (state.settings.soundEffects) {
    playSound(result.emotion);
  }
}

function closeResult() {
  elements.resultOverlay.classList.add('hidden');
}

function showPanel(panel) {
  if (panel === 'history') {
    renderHistory();
    elements.historyPanel.classList.remove('hidden');
  } else if (panel === 'settings') {
    elements.settingsPanel.classList.remove('hidden');
  }
}

function hidePanel(panel) {
  if (panel === 'history') {
    elements.historyPanel.classList.add('hidden');
  } else if (panel === 'settings') {
    elements.settingsPanel.classList.add('hidden');
  }
}

function animateFaceGuide() {
  // Subtle pulsing animation for the face guide
  const guide = elements.faceGuide;
  let scale = 1;
  let growing = true;
  
  setInterval(() => {
    if (growing) {
      scale += 0.005;
      if (scale >= 1.05) growing = false;
    } else {
      scale -= 0.005;
      if (scale <= 0.95) growing = true;
    }
    guide.style.transform = `translate(-50%, -50%) scale(${scale})`;
  }, 50);
}

function updateTime() {
  const now = new Date();
  const hours = now.getHours();
  const minutes = now.getMinutes().toString().padStart(2, '0');
  elements.timeDisplay.textContent = `${hours}:${minutes}`;
}

// ========================================
// Storage Functions
// ========================================
function saveToHistory(result) {
  const history = getHistory();
  
  const entry = {
    id: Date.now(),
    emotion: result.emotion,
    confidence: result.confidence,
    timestamp: new Date().toISOString(),
    suggestions: EMOTION_DATA[result.emotion]?.suggestions || []
  };
  
  history.unshift(entry);
  
  // Keep only last 50 entries
  if (history.length > 50) {
    history.pop();
  }
  
  localStorage.setItem(CONFIG.STORAGE_KEY, JSON.stringify(history));
}

function getHistory() {
  try {
    const data = localStorage.getItem(CONFIG.STORAGE_KEY);
    return data ? JSON.parse(data) : [];
  } catch (error) {
    console.error('Error reading history:', error);
    return [];
  }
}

function clearHistory() {
  if (confirm('Are you sure you want to clear all scan history?')) {
    localStorage.removeItem(CONFIG.STORAGE_KEY);
    renderHistory();
  }
}

function renderHistory() {
  const history = getHistory();
  
  if (history.length === 0) {
    elements.historyList.innerHTML = `
      <div class="empty-state">
        <div class="empty-state-icon">📋</div>
        <h3>No history yet</h3>
        <p>Start scanning your baby's emotions to build a history</p>
      </div>
    `;
    elements.clearHistoryBtn.classList.add('hidden');
    return;
  }
  
  elements.historyList.innerHTML = history.map(entry => {
    const emotionData = EMOTION_DATA[entry.emotion] || EMOTION_DATA.neutral;
    const date = new Date(entry.timestamp);
    const timeStr = date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    const dateStr = date.toLocaleDateString([], { month: 'short', day: 'numeric' });
    
    return `
      <div class="history-card" data-id="${entry.id}">
        <div class="history-emoji" style="background: ${emotionData.color}20">
          ${emotionData.emoji}
        </div>
        <div class="history-info">
          <div class="history-emotion">${emotionData.name}</div>
          <div class="history-time">${dateStr} at ${timeStr}</div>
        </div>
        <div class="history-confidence">${Math.round(entry.confidence * 100)}%</div>
      </div>
    `;
  }).join('');
  
  elements.clearHistoryBtn.classList.remove('hidden');
}

// ========================================
// Settings Functions
// ========================================
function loadSettings() {
  try {
    const data = localStorage.getItem(CONFIG.SETTINGS_KEY);
    if (data) {
      state.settings = { ...state.settings, ...JSON.parse(data) };
    }
    
    // Update UI
    document.getElementById('auto-save').checked = state.settings.autoSave;
    document.getElementById('show-confidence').checked = state.settings.showConfidence;
    document.getElementById('sound-effects').checked = state.settings.soundEffects;
  } catch (error) {
    console.error('Error loading settings:', error);
  }
}

function saveSettings() {
  localStorage.setItem(CONFIG.SETTINGS_KEY, JSON.stringify(state.settings));
}

// ========================================
// Audio Functions
// ========================================
function playSound(emotion) {
  // Simple audio feedback
  try {
    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
    const oscillator = audioContext.createOscillator();
    const gainNode = audioContext.createGain();
    
    oscillator.connect(gainNode);
    gainNode.connect(audioContext.destination);
    
    // Different tones for positive vs negative emotions
    const isPositive = ['happy', 'laughing'].includes(emotion);
    oscillator.frequency.value = isPositive ? 523.25 : 392; // C5 or G4
    oscillator.type = 'sine';
    gainNode.gain.value = 0.1;
    
    oscillator.start();
    oscillator.stop(audioContext.currentTime + 0.15);
  } catch (error) {
    // Audio not supported or blocked
  }
}

// ========================================
// Utility Functions
// ========================================
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// ========================================
// Initialize App
// ========================================
document.addEventListener('DOMContentLoaded', init);
