# 🍼 Baby Cry Emotion Detector

**Simple backend for detecting baby cry emotions using deep learning**

Combined from [babycry](https://github.com/martha92/babycry) + [DeepInfant](https://github.com/skytells-research/DeepInfant) repositories with all overlapping code removed.

---

## ✨ Features

- 🎯 Detects **8 types of baby cries**
- 🧠 CNN-LSTM-Attention deep learning model
- 🎵 Advanced audio processing with mel-spectrograms
- ⚡ Real-time prediction capable
- 🚫 **No audio files needed for testing!**

---

## 📋 Cry Types Detected

1. **Hungry** - Baby needs food
2. **Burping** - Baby needs to burp
3. **Belly Pain** - Stomach discomfort
4. **Discomfort** - General discomfort
5. **Tired** - Baby is sleepy
6. **Lonely** - Wants attention
7. **Cold/Hot** - Temperature issue
8. **Scared** - Baby is frightened

---

## 🚀 Quick Start

### Installation

```bash
# 1. Clone or download this repository
git clone https://github.com/yourusername/baby-emotion-detector.git
cd baby-emotion-detector

# 2. Install dependencies
pip install -r requirements.txt
```

### Basic Usage

```python
from backend import BabyCryPredictor

# Create predictor
predictor = BabyCryPredictor()

# Predict from audio file
result = predictor.predict('baby_cry.wav')

print(f"Cry type: {result['cry_type']}")
print(f"Confidence: {result['confidence']:.2%}")
```

### Testing Without Audio Files

```python
import numpy as np
from backend import BabyCryPredictor

# Create predictor
predictor = BabyCryPredictor()

# Generate random audio for testing
fake_audio = np.random.randn(16000 * 7)  # 7 seconds

# Predict
result = predictor.predict_from_numpy(fake_audio)
print(result)
```

---

## 📁 Repository Structure

```
baby-emotion-detector/
├── backend.py         ← Main backend code
├── requirements.txt   ← Dependencies
├── example.py         ← Usage examples
└── README.md          ← This file
```

**That's it!** Just 4 files total.

---

## 🔧 How It Works

### 1. Audio Processing
- Loads audio at 16kHz sample rate
- Converts to mel-spectrogram (frequency representation)
- Applies log scaling and normalization
- Pads/truncates to fixed size (128×381)

### 2. Model Architecture
- **CNN layers**: Extract frequency features
- **LSTM layer**: Model temporal patterns
- **Attention mechanism**: Focus on important frames
- **Dense layers**: Final classification

### 3. Prediction
- Takes mel-spectrogram as input
- Outputs probabilities for 8 cry types
- Returns most likely cry type + confidence

---

## 📊 Model Architecture

```
Input (128, 381) mel-spectrogram
    ↓
Conv2D (128 filters) + BatchNorm + MaxPool + Dropout
    ↓
Conv2D (256 filters) + BatchNorm + MaxPool + Dropout
    ↓
LSTM (128 units) + Dropout
    ↓
Attention Layer
    ↓
Dense (256) + BatchNorm + Dropout
    ↓
Dense (128) + Dropout
    ↓
Output (8 classes) - Softmax
```

**Total Parameters**: ~2-3 million (depending on exact configuration)

---

## 💻 Advanced Usage

### Load Pre-trained Model

```python
predictor = BabyCryPredictor(model_path='my_trained_model.h5')
result = predictor.predict('baby_cry.wav')
```

### Save Model

```python
predictor = BabyCryPredictor()
# ... train the model ...
predictor.save_model('my_trained_model.h5')
```

### Real-time Audio Recording

```python
import sounddevice as sd
from backend import BabyCryPredictor

predictor = BabyCryPredictor(model_path='trained_model.h5')

# Record 7 seconds from microphone
print("Recording...")
audio = sd.rec(int(7 * 16000), samplerate=16000, channels=1)
sd.wait()

# Predict
result = predictor.predict_from_numpy(audio.flatten())
print(f"Detected: {result['cry_type']} ({result['confidence']:.1%})")
```

### Get All Probabilities

```python
result = predictor.predict('baby_cry.wav')

for cry_type, probability in result['all_probabilities'].items():
    print(f"{cry_type}: {probability:.2%}")
```

---

## 🧪 Running Examples

```bash
python example.py
```

This will run 6 examples showing:
1. Creating the predictor
2. Testing with random audio
3. Predicting from files
4. Multiple predictions
5. Saving/loading models
6. Real-time recording

---

## 📦 Dependencies

- **TensorFlow/Keras** - Deep learning framework
- **Librosa** - Audio processing
- **NumPy** - Numerical operations
- **SoundFile** - Audio file I/O

Optional:
- **SoundDevice** - For real-time microphone recording

---

## 🎓 Based On

This backend combines the best parts of:

- **[babycry](https://github.com/martha92/babycry)** by Martha Garcia et al.
  - CNN-LSTM-Attention architecture
  - 8 cry classifications
  - Attention mechanism

- **[DeepInfant](https://github.com/skytells-research/DeepInfant)** by Skytells AI Research
  - Mel-spectrogram processing
  - STFT feature extraction
  - 89% accuracy approach

All overlapping code has been removed to create a clean, minimal backend.

---

## ⚠️ Important Notes

1. **Model is untrained by default** - You need to either:
   - Train it on your own data
   - Load a pre-trained model
   - Use it for architecture testing

2. **Audio format** - Works best with:
   - 16kHz sample rate
   - Mono (1 channel)
   - WAV format
   - 7 seconds duration

3. **No training code included** - This is just the backend/inference code. Training requires:
   - Labeled dataset
   - Training loop
   - Data augmentation

---

## 📝 License

MIT License - Feel free to use for any purpose

---

## 🤝 Contributing

Contributions welcome! This is a minimal backend, so improvements could include:
- Training scripts
- Data augmentation
- Model optimizations
- API wrapper
- Mobile deployment

---

## 📧 Contact

For questions or issues, please open a GitHub issue.

---

**Made with ❤️ for parents and caregivers**
