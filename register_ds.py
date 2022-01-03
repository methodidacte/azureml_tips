# check core SDK version number
import azureml.core
from azureml.core import Workspace
from azureml.core import Datastore
from azureml.core import Dataset
from azureml.data.datapath import DataPath


print(f'Azure ML SDK Version: {azureml.core.VERSION}')
ws = Workspace.from_config()

# Register dataset
mydsstore = Datastore.get(ws, "workspaceblobstore")
mydsstore.upload(src_dir='./data', target_path='up/', overwrite=True)

dataset = Dataset.Tabular.from_delimited_files(path = DataPath(mydsstore, 'up/german_credit_init.csv'))
dataset.register(ws, "german_credit_dataset_from_local")
print('Dataset registered')
