import csv
import sys
# Input and output file paths
input_file = sys.argv[1]
output_file = sys.argv[2]

# Define the headers for the new columns
new_column_headers = ["kingdom", "phylum", "class", "order", "family", "genus", "species"]

# Create a dictionary to map field names to new column values
field_mapping = {
    "d": "kingdom",
    "p": "phylum",
    "c": "class",
    "o": "order",
    "f": "family",
    "g": "genus",
    "s": "species",
}

# Function to extract and map the values to the new columns
def extract_and_map_values(input_row):
    last_column = input_row.pop()  # Remove the last column
    field_values = {field: "" for field in new_column_headers}

    parts = last_column.split(",")
    
    for part in parts:
        field_prefix, value = part.split(":") if ":" in part else (None, part)
        new_column = field_mapping.get(field_prefix)
        if new_column:
            field_values[new_column] = f"{new_column}__{value}"

    new_row = input_row + [field_values[field] for field in new_column_headers]

    return new_row

# Open the input and output files
with open(input_file, mode="r") as infile, open(output_file, mode="w", newline="") as outfile:
    reader = csv.reader(infile, delimiter="\t")
    writer = csv.writer(outfile, delimiter="\t")

    # Write the headers with the new columns
    headers = next(reader)[:-1] + new_column_headers
    writer.writerow(headers)

    # Process and write the data
    for row in reader:
        modified_row = extract_and_map_values(row)
        writer.writerow(modified_row)
