import subprocess
import datetime

bucket_name = 'yfpstaginginfrastack-yielddatabucketdc1ea238-z8k4blsc6ozn'
source_folder = 'json-data/'
archive_folder = 'archive_2024/'

# List all files in the json-data folder
list_files_command = f"aws s3 ls s3://{bucket_name}/{source_folder} --recursive"
result = subprocess.run(list_files_command, shell=True, capture_output=True, text=True)

# Parse the output
files = result.stdout.splitlines()
print(f"All files {len(files)}")
# Date to compare
compare_date = datetime.datetime.strptime('2024-06-03', '%Y-%m-%d')

# Prepare a list for files to move
files_to_move = []

for file in files:
    parts = file.split(maxsplit=3)
    if len(parts) < 4:
        continue
    date_str, time_str, _, key = parts
    print(f"All files {date_str}")
    file_date = datetime.datetime.strptime(f"{date_str} {time_str}", '%Y-%m-%d %H:%M:%S')
    
    if file_date <= compare_date and key.endswith('.json'):
        files_to_move.append(key)

# Move the files
counter=0
for key in files_to_move:
    move_command = f"aws s3 mv s3://{bucket_name}/{key} s3://{bucket_name}/{archive_folder}{key}"
    subprocess.run(move_command, shell=True)
    counter += 1
    if counter > 500:
        break

print(f"Moved {len(files_to_move)} JSON files to {archive_folder}. Counter {counter}")
