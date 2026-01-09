"""
Baby Cry Detector - Usage Examples
FILE: example.py

Shows how to use the baby cry detector with different inputs
"""

from backend import BabyCryPredictor, Config
import numpy as np

def main():
    print("=" * 70)
    print("BABY CRY DETECTOR - EXAMPLES")
    print("=" * 70)
    
    # ========================================================================
    # EXAMPLE 1: Create predictor
    # ========================================================================
    print("\n📌 EXAMPLE 1: Creating the predictor")
    print("-" * 70)
    
    predictor = BabyCryPredictor()
    print("✅ Predictor created!")
    print(f"Can detect {len(Config.CRY_LABELS)} cry types: {', '.join(Config.CRY_LABELS)}")
    
    # ========================================================================
    # EXAMPLE 2: Test with random audio (NO FILE NEEDED!)
    # ========================================================================
    print("\n📌 EXAMPLE 2: Testing with random audio (no real audio needed)")
    print("-" * 70)
    
    # Generate 7 seconds of random audio
    fake_audio = np.random.randn(16000 * 7)
    
    print("Testing with random noise...")
    result = predictor.predict_from_numpy(fake_audio)
    
    print(f"Predicted cry type: {result['cry_type']}")
    print(f"Confidence: {result['confidence']:.2%}")
    print("\nAll probabilities:")
    for cry_type, prob in result['all_probabilities'].items():
        print(f"  {cry_type:12s}: {prob:.2%}")
    
    # ========================================================================
    # EXAMPLE 3: Predict from audio file (if you have one)
    # ========================================================================
    print("\n📌 EXAMPLE 3: Predicting from audio file")
    print("-" * 70)
    print("Code example:")
    print("""
# If you have a baby cry audio file:
# result = predictor.predict('baby_cry.wav')
# print(f"Cry type: {result['cry_type']}")
# print(f"Confidence: {result['confidence']:.2%}")
    """)
    
    # ========================================================================
    # EXAMPLE 4: Multiple predictions
    # ========================================================================
    print("\n📌 EXAMPLE 4: Making multiple predictions")
    print("-" * 70)
    
    print("Running 3 predictions with different random audio...")
    for i in range(3):
        test_audio = np.random.randn(16000 * 7)
        result = predictor.predict_from_numpy(test_audio)
        print(f"  Test {i+1}: {result['cry_type']} ({result['confidence']:.1%})")
    
    # ========================================================================
    # EXAMPLE 5: Save model
    # ========================================================================
    print("\n📌 EXAMPLE 5: Saving the model")
    print("-" * 70)
    print("To save your model after training:")
    print("predictor.save_model('my_trained_model.h5')")
    print("\nTo load a saved model:")
    print("predictor = BabyCryPredictor(model_path='my_trained_model.h5')")
    
    # ========================================================================
    # EXAMPLE 6: Real-time audio (optional)
    # ========================================================================
    print("\n📌 EXAMPLE 6: Real-time audio recording (requires sounddevice)")
    print("-" * 70)
    print("Code example:")
    print("""
# Install: pip install sounddevice
import sounddevice as sd

# Record 7 seconds of audio from microphone
print("Recording... speak or play baby cry sound...")
audio = sd.rec(int(7 * 16000), samplerate=16000, channels=1)
sd.wait()  # Wait until recording is finished

# Predict
result = predictor.predict_from_numpy(audio.flatten())
print(f"Detected: {result['cry_type']}")
    """)
    
    print("\n" + "=" * 70)
    print("DONE! All examples completed.")
    print("=" * 70)

if __name__ == "__main__":
    main()
