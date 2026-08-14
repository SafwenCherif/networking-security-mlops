from dotenv import load_dotenv

load_dotenv()

from networksecurity.pipeline.training_pipeline import TrainingPipeline
from networksecurity.exception.exception import NetworkSecurityException
import sys

if __name__ == "__main__":
    try:
        pipeline = TrainingPipeline()
        artifact = pipeline.run_pipeline()
        print(artifact)
    except Exception as e:
        raise NetworkSecurityException(e, sys)
