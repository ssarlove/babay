"""
BABY CRY EMOTION DETECTOR - CORE BACKEND
Combined from babycry + DeepInfant repositories
No overlapping code - just the essentials!

FILE: backend.py
"""

import numpy as np
import librosa
from tensorflow import keras
from tensorflow.keras import layers

# ============================================================================
# CONFIGURATION
# ============================================================================

class Config:
    """Configuration for baby cry detection"""
    SAMPLE_RATE = 16000
    N_MELS = 128
    N_FFT = 2048
    HOP_LENGTH = 512
    DURATION = 7
    
    # 8 cry types detected
    CRY_LABELS = [
        'hungry',      # Baby needs food
        'burping',     # Baby needs to burp
        'belly_pain',  # Baby has stomach pain
        'discomfort',  # Baby is uncomfortable
        'tired',       # Baby is sleepy
        'lonely',      # Baby wants attention
        'cold_hot',    # Baby is too cold or hot
        'scared'       # Baby is frightened
    ]

# ============================================================================
# MODEL ARCHITECTURE (From babycry + DeepInfant)
# ============================================================================

def build_baby_cry_model(input_shape=(128, 381), num_classes=8):
    """
    Build CNN-LSTM-Attention model for baby cry classification
    
    Architecture:
    - CNN layers: Extract frequency features from mel-spectrogram
    - LSTM layer: Model temporal patterns in crying
    - Attention: Focus on important time frames
    - Dense layers: Final classification
    
    Args:
        input_shape: (n_mels, time_frames) - default (128, 381)
        num_classes: Number of cry types - default 8
        
    Returns:
        Compiled Keras model
    """
    inputs = keras.Input(shape=input_shape, name='mel_spectrogram_input')
    
    # Reshape for CNN processing
    x = layers.Reshape((input_shape[0], input_shape[1], 1))(inputs)
    
    # CNN Block 1: Extract low-level audio features
    x = layers.Conv2D(128, (5, 5), activation='relu', padding='same')(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPooling2D((3, 3))(x)
    x = layers.Dropout(0.3)(x)
    
    # CNN Block 2: Extract high-level audio features
    x = layers.Conv2D(256, (3, 3), activation='relu', padding='same')(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPooling2D((2, 2))(x)
    x = layers.Dropout(0.3)(x)
    
    # Reshape for LSTM (temporal modeling)
    shape = x.shape
    x = layers.Reshape((shape[1], shape[2] * shape[3]))(x)
    
    # LSTM: Model temporal patterns in cry
    x = layers.LSTM(128, return_sequences=True)(x)
    x = layers.Dropout(0.3)(x)
    
    # Attention Mechanism: Focus on important frames
    attention = layers.Dense(1, activation='tanh')(x)
    attention = layers.Flatten()(attention)
    attention = layers.Activation('softmax')(attention)
    attention = layers.RepeatVector(128)(attention)
    attention = layers.Permute([2, 1])(attention)
    
    # Apply attention weights
    x = layers.Multiply()([x, attention])
    x = layers.Lambda(lambda xin: keras.backend.sum(xin, axis=1))(x)
    
    # Dense layers for classification
    x = layers.Dense(256, activation='relu')(x)
    x = layers.BatchNormalization()(x)
    x = layers.Dropout(0.5)(x)
    
    x = layers.Dense(128, activation='relu')(x)
    x = layers.Dropout(0.3)(x)
    
    # Output layer
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    
    # Create and compile model
    model = keras.Model(inputs=inputs, outputs=outputs, name='BabyCryDetector')
    
    model.compile(
        optimizer='adam',
        loss='categorical_crossentropy',
        metrics=['accuracy']
    )
    
    return model

# ============================================================================
# AUDIO FEATURE EXTRACTION (From DeepInfant)
# ============================================================================

def extract_mel_spectrogram(audio_path):
    """
    Extract mel-spectrogram features from audio file
    
    Process:
    1. Load audio file at 16kHz
    2. Convert to mel-spectrogram (frequency representation)
    3. Convert to log scale (human hearing is logarithmic)
    4. Normalize features
    5. Pad/truncate to fixed size
    
    Args:
        audio_path: Path to .wav audio file
        
    Returns:
        numpy array of shape (128, 381) - mel-spectrogram
    """
    # Load audio file
    audio, sr = librosa.load(
        audio_path, 
        sr=Config.SAMPLE_RATE, 
        duration=Config.DURATION
    )
    
    # Extract mel-spectrogram
    mel_spec = librosa.feature.melspectrogram(
        y=audio,
        sr=sr,
        n_fft=Config.N_FFT,
        hop_length=Config.HOP_LENGTH,
        n_mels=Config.N_MELS
    )
    
    # Convert to log scale (dB)
    log_mel_spec = librosa.power_to_db(mel_spec, ref=np.max)
    
    # Pad or truncate to fixed length (381 frames)
    target_length = 381
    if log_mel_spec.shape[1] < target_length:
        # Pad with zeros if too short
        log_mel_spec = np.pad(
            log_mel_spec,
            ((0, 0), (0, target_length - log_mel_spec.shape[1])),
            mode='constant'
        )
    else:
        # Truncate if too long
        log_mel_spec = log_mel_spec[:, :target_length]
    
    # Normalize (zero mean, unit variance)
    log_mel_spec = (log_mel_spec - np.mean(log_mel_spec)) / (np.std(log_mel_spec) + 1e-8)
    
    return log_mel_spec

# ============================================================================
# MAIN PREDICTOR CLASS
# ============================================================================

class BabyCryPredictor:
    """
    Baby Cry Emotion Detector
    
    Main class for predicting baby cry reasons from audio.
    Can predict from audio files or real-time audio streams.
    
    Usage:
        predictor = BabyCryPredictor()
        result = predictor.predict('baby_cry.wav')
        print(result['cry_type'], result['confidence'])
    """
    
    def __init__(self, model_path=None):
        """
        Initialize predictor
        
        Args:
            model_path: Optional path to pre-trained model (.h5 file)
                       If None, creates a new untrained model
        """
        if model_path:
            print(f"Loading model from {model_path}...")
            self.model = keras.models.load_model(model_path)
            print("✅ Model loaded successfully!")
        else:
            print("Creating new model architecture...")
            self.model = build_baby_cry_model()
            print("⚠️  Model created but NOT TRAINED")
            print("   You need to train it or load a pre-trained model")
    
    def predict(self, audio_path):
        """
        Predict baby cry reason from audio file
        
        Args:
            audio_path: Path to .wav audio file (16kHz recommended)
            
        Returns:
            dict with:
                - cry_type: Predicted cry reason
                - confidence: Confidence score (0-1)
                - all_probabilities: Probabilities for all classes
        """
        # Extract features from audio
        features = extract_mel_spectrogram(audio_path)
        
        # Add batch dimension
        features = np.expand_dims(features, axis=0)
        
        # Make prediction
        prediction = self.model.predict(features, verbose=0)
        
        # Get results
        predicted_class = np.argmax(prediction[0])
        confidence = prediction[0][predicted_class]
        
        return {
            'cry_type': Config.CRY_LABELS[predicted_class],
            'confidence': float(confidence),
            'all_probabilities': {
                label: float(prob) 
                for label, prob in zip(Config.CRY_LABELS, prediction[0])
            }
        }
    
    def predict_from_numpy(self, audio_array, sample_rate=16000):
        """
        Predict from numpy array (for real-time audio or testing)
        
        Args:
            audio_array: 1D numpy array of audio samples
            sample_rate: Sample rate of the audio (default 16000)
            
        Returns:
            dict with prediction results (same as predict())
        """
        # Resample if necessary
        if sample_rate != Config.SAMPLE_RATE:
            audio_array = librosa.resample(
                audio_array, 
                orig_sr=sample_rate, 
                target_sr=Config.SAMPLE_RATE
            )
        
        # Ensure correct length (7 seconds)
        expected_length = Config.SAMPLE_RATE * Config.DURATION
        if len(audio_array) < expected_length:
            # Pad if too short
            audio_array = np.pad(
                audio_array,
                (0, expected_length - len(audio_array)),
                mode='constant'
            )
        else:
            # Truncate if too long
            audio_array = audio_array[:expected_length]
        
        # Extract mel-spectrogram
        mel_spec = librosa.feature.melspectrogram(
            y=audio_array,
            sr=Config.SAMPLE_RATE,
            n_fft=Config.N_FFT,
            hop_length=Config.HOP_LENGTH,
            n_mels=Config.N_MELS
        )
        
        log_mel_spec = librosa.power_to_db(mel_spec, ref=np.max)
        
        # Pad/truncate to 381 frames
        target_length = 381
        if log_mel_spec.shape[1] < target_length:
            log_mel_spec = np.pad(
                log_mel_spec,
                ((0, 0), (0, target_length - log_mel_spec.shape[1])),
                mode='constant'
            )
        else:
            log_mel_spec = log_mel_spec[:, :target_length]
        
        # Normalize
        log_mel_spec = (log_mel_spec - np.mean(log_mel_spec)) / (np.std(log_mel_spec) + 1e-8)
        
        # Add batch dimension
        log_mel_spec = np.expand_dims(log_mel_spec, axis=0)
        
        # Predict
        prediction = self.model.predict(log_mel_spec, verbose=0)
        predicted_class = np.argmax(prediction[0])
        
        return {
            'cry_type': Config.CRY_LABELS[predicted_class],
            'confidence': float(prediction[0][predicted_class]),
            'all_probabilities': {
                label: float(prob) 
                for label, prob in zip(Config.CRY_LABELS, prediction[0])
            }
        }
    
    def save_model(self, path='baby_cry_model.h5'):
        """
        Save model to file
        
        Args:
            path: Where to save the model (default: baby_cry_model.h5)
        """
        self.model.save(path)
        print(f"✅ Model saved to {path}")
    
    def get_model_summary(self):
        """Print model architecture summary"""
        self.model.summary()

# ============================================================================
# DEMO / TESTING
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("BABY CRY EMOTION DETECTOR - BACKEND")
    print("=" * 70)
    
    # Create predictor
    print("\n1. Creating predictor...")
    predictor = BabyCryPredictor()
    
    print("\n2. Model information:")
    print(f"   Input shape: (128, 381) mel-spectrogram")
    print(f"   Output: {len(Config.CRY_LABELS)} cry types")
    print(f"   Cry types detected:")
    for i, label in enumerate(Config.CRY_LABELS, 1):
        print(f"      {i}. {label}")
    
    print("\n3. Model architecture:")
    predictor.get_model_summary()
    
    print("\n" + "=" * 70)
    print("HOW TO USE:")
    print("=" * 70)
    print("""
# Example 1: Predict from audio file
from backend import BabyCryPredictor

predictor = BabyCryPredictor()
result = predictor.predict('baby_cry.wav')
print(f"Cry type: {result['cry_type']}")
print(f"Confidence: {result['confidence']:.2%}")

# Example 2: Test with random audio (no file needed!)
import numpy as np
fake_audio = np.random.randn(16000 * 7)  # 7 seconds
result = predictor.predict_from_numpy(fake_audio)
print(result)

# Example 3: Load pre-trained model
predictor = BabyCryPredictor(model_path='my_trained_model.h5')
result = predictor.predict('baby_cry.wav')
    """)
    print("=" * 70)
