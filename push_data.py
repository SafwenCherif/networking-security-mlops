import os
import sys
import json

from dotenv import load_dotenv

load_dotenv()

MONGO_DB_URL = os.getenv("MONGO_DB_URL")

import certifi

ca = certifi.where()

import pandas as pd
import pymongo
from networksecurity.exception.exception import NetworkSecurityException
from networksecurity.logging.logger import logging
from networksecurity.constant.training_pipeline import (
    DATA_INGESTION_DATABASE_NAME,
    DATA_INGESTION_COLLECTION_NAME,
)

LEGACY_DATABASE_NAME = "KRISHAI"


class NetworkDataExtract:
    def __init__(self):
        try:
            self.mongo_client = pymongo.MongoClient(MONGO_DB_URL, tlsCAFile=ca)
        except Exception as e:
            raise NetworkSecurityException(e, sys)

    def csv_to_json_convertor(self, file_path):
        try:
            logging.info(f"Reading CSV file: {file_path}")
            data = pd.read_csv(file_path)
            data.reset_index(drop=True, inplace=True)
            records = list(json.loads(data.T.to_json()).values())
            logging.info(f"Converted CSV to {len(records)} JSON records")
            return records
        except Exception as e:
            raise NetworkSecurityException(e, sys)

    def insert_data_mongodb(self, records, database, collection):
        try:
            logging.info(f"Inserting records into {database}.{collection}")
            database_obj = self.mongo_client[database]
            collection_obj = database_obj[collection]
            collection_obj.insert_many(records)
            inserted_count = len(records)
            logging.info(f"Successfully inserted {inserted_count} records")
            return inserted_count
        except Exception as e:
            raise NetworkSecurityException(e, sys)

    def remove_legacy_database(self, legacy_database_name: str):
        try:
            if legacy_database_name in self.mongo_client.list_database_names():
                self.mongo_client.drop_database(legacy_database_name)
                logging.info(f"Removed legacy database: {legacy_database_name}")
            else:
                logging.info(f"Legacy database not found (skip): {legacy_database_name}")
        except Exception as e:
            raise NetworkSecurityException(e, sys)


if __name__ == "__main__":
    FILE_PATH = os.path.join("Network_Data", "phisingData.csv")
    DATABASE = DATA_INGESTION_DATABASE_NAME
    COLLECTION = DATA_INGESTION_COLLECTION_NAME

    logging.info("Starting MongoDB ETL pipeline")
    networkobj = NetworkDataExtract()
    networkobj.remove_legacy_database(LEGACY_DATABASE_NAME)

    records = networkobj.csv_to_json_convertor(file_path=FILE_PATH)
    no_of_records = networkobj.insert_data_mongodb(records, DATABASE, COLLECTION)
    print(f"ETL completed: {no_of_records} records loaded into {DATABASE}.{COLLECTION}")
