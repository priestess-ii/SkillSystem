def parse_blocks(lines):
    blocks = []
    current_block = []
    do_not_sort_index = None

    for i, line in enumerate(lines):
        stripped = line.strip()

        # Check for stop-sorting signal
        if stripped.lower().startswith("// do not sort"):
            if current_block:
                blocks.append(current_block)
                current_block = []
            do_not_sort_index = len(blocks)
            blocks.append([line])  # Keep the DO NOT SORT line as its own block
            continue

        if stripped == "":
            if current_block:
                blocks.append(current_block)
                current_block = []
        else:
            current_block.append(line)

    if current_block:
        blocks.append(current_block)

    return blocks, do_not_sort_index

def get_first_id(block):
    for line in block:
        if not line.strip().startswith("//"):
            return line.strip()
    return ""  # Fallback if no IDs are found

def sort_blocks(blocks, stop_index=None):
    if stop_index is None:
        return sorted(blocks, key=get_first_id)
    else:
        sortable = blocks[:stop_index]
        unsorted = blocks[stop_index:]
        return sorted(sortable, key=get_first_id) + unsorted

def main():
    input_file = "input.txt"
    output_file = "sorted_output.txt"

    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    blocks, stop_index = parse_blocks(lines)
    sorted_blocks = sort_blocks(blocks, stop_index)

    with open(output_file, "w", encoding="utf-8") as f:
        for block in sorted_blocks:
            for line in block:
                f.write(line.rstrip() + "\n")
            f.write("\n")

    print(f"Sorted output written to {output_file}")

if __name__ == "__main__":
    main()
