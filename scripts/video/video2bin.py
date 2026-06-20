"""Converts a video to a binary file suitable for Lua decoding on the Galactic Unicorn"""

import os
import shutil

try:
    import cv2
except ImportError:
    print(
        "OpenCV is not installed. "
        "Please install it with 'pip install opencv-python' to run this script."
    )
    exit(1)

try:
    from PIL import Image
except ImportError:
    print(
        "PIL is not installed. "
        "Please install it with 'pip install Pillow' to run this script."
    )
    exit(1)


root = os.getcwd()

# Hardcoded lookup table for encodings identifiers
ENCODINGS = {
    "invalid":          0,
    "1bit-grayscale":   1,
    "2bit-grayscale":   2,
    "4bit-grayscale":   3,
    "8bit-rgb332":      4,
    "16bit-rgb565":     5
}

ENCODING = ENCODINGS["16bit-rgb565"]
IMAGE_SIZE = (20, 10)

video_file = "rickroll.mp4"
frames_destination_dir = "frames"
frames_destination_format = "png"  # Prefer lossless
frame_step = 1  # Extract 1/frame_step of the frames
output_file = "frames.guv"


def extract_frames():
    """Extract individual frames from a video file as image files
    adapted from:
        https://gist.github.com/SebOh/5d2438c7987591757a3591495720a5e7
    """

    directory = os.path.join(root, frames_destination_dir)

    # Always start with an empty output directory
    if os.path.exists(directory):
        shutil.rmtree(directory)
    os.makedirs(directory)

    image_counter = 0
    read_counter = 0

    cap = cv2.VideoCapture(video_file)
    
    framerate = cap.get(cv2.CAP_PROP_FPS)

    while cap.isOpened():
        ret, cv2_im = cap.read()
        if ret and read_counter % frame_step == 0:
            converted = cv2.cvtColor(cv2_im, cv2.COLOR_BGR2RGB)

            pil_im = Image.fromarray(converted)

            if IMAGE_SIZE:
                pil_im_resize = pil_im.resize(IMAGE_SIZE)
            else:
                pil_im_resize = pil_im

            pil_im_resize.save(
                os.path.join(
                    root,
                    frames_destination_dir,
                    str(image_counter) + "." + frames_destination_format,
                )
            )
            image_counter += 1
        elif not ret:
            break
        read_counter += 1

    cap.release()
    
    return framerate


def read_frame(frame_path, color=False):
    """Reads a frame from an image file"""
    color_format = "RGB" if color else "L"
    return Image.open(frame_path).convert(color_format).get_flattened_data()


def convert_frame_1bit(frame):
    """1bit color: black or white
    We can pack 8 pixels per byte
    """
    out = bytearray()
    for i in range(0, len(frame), 8):
        byte = 0
        for bit in range(8):  # 8 pixels per byte
            if frame[i + bit] > 127:  # Threshold to 1 bit per pixel
                # Write the bit in the correct position in the byte
                byte |= 1 << (7 - bit)
        out.append(byte)
    return out


def convert_frame_2bit(frame):
    """2bit color: 4 shades of grey
    We can pack 4 pixels per byte
    """
    out = bytearray()
    for i in range(0, len(frame), 4):
        byte = 0
        for j in range(4):
            val = frame[i + j] >> 6
            # 00000011 -> 11000000; j=0; val << 6
            # 00000022 -> 00220000; j=1; val << 4
            # 00000033 -> 00003300; j=2; val << 2
            # 00000044 -> 00000044; j=3; val << 0
            byte |= val << (6 - 2 * j)
        out.append(byte)
    return out


def convert_frame_4bit(frame):
    """4bit color: 16 shades of grey
    We can pack two pixels per byte (one nibble each)
    """
    out = bytearray()
    for i in range(0, len(frame), 2):  # two pixels per byte
        high = frame[i] >> 4  # First pixel, upper nibble
        low = frame[i + 1] >> 4  # Second pixel, lower nibble
        out.append((high << 4) | low)
    return out


def convert_frame_8bit_rgb332(frame):
    """8bit color: 256 colors
    RGB332: 3 bits of red, 3 bits of green, 2 bits of blue
    1 pixel per byte
    """
    out = bytearray()
    for i in range(0, len(frame)):
        r = frame[i][0] >> 5  # get the top 3 bits of red RRRRRRRR -> 00000RRR
        g = frame[i][1] >> 5  # top 3 bits of green       GGGGGGGG -> 00000GGG
        b = frame[i][2] >> 6  # top 2 bits of blue        BBBBBBBB -> 000000BB

        # Now to pack them correctly in a byte as RRRGGGBB
        # r << 5 = RRR00000
        # g << 2 = 000GGG00
        # b      = 000000BB
        # r << 5 | g << 2 | b = RRRGGGBB
        color_8bit = r << 5 | g << 2 | b

        out.append(color_8bit)

    return out


def convert_frame_16bit_rgb565(frame):
    """16bit color: 65536 possible colors
    RGB565: 5 bits of red, 6 bits of green, 5 bits of blue
    1 pixel is two bytes
    """
    out = bytearray()
    for i in range(0, len(frame)):
        r = frame[i][0] >> 3  # get the top 5 bits of red RRRRRRRR -> 000RRRRR
        g = frame[i][1] >> 2  # top 6 bits of green       GGGGGGGG -> 00GGGGGG
        b = frame[i][2] >> 3  # top 5 bits of blue        BBBBBBBB -> 000BBBBB

        # Now to pack them correctly in two bytes as RRRRRGGG GGGBBBBB
        # First byte: all the bits of r shifted to the start of the byte
        # + first 3 bits of g shifted down to keep only the first 3 bits
        first_byte = r << 3 | g >> 3
        out.append(first_byte)

        # Second byte: last three bits of g shifted to the start of the byte
        # + all the bits of b
        second_byte = ((g & 0b00000111) << 5) | b # Could have also written 0x07 in hex or just 7 in decimal
        out.append(second_byte)
    return out


def make_header(encoding: int, width: int, height: int, framerate: int):
    """Make a header that describes the binary file

    File layout:
    offset  size    field
    0       3       magic_number    -
    3       1       version         |
    4       1       encoding        |
    5       1       framerate       |- header
    6       1       width           |
    7       1       height          -
    8       ...     framedata

    """
    
    # magic_number is a file format identifier at the very start of the file
    # see https://en.wikipedia.org/wiki/File_format#Magic_number
    magic_number = "GUV".encode("ascii") # Galactic Unicorn Video
    version = 1

    header = bytearray()
    
    header += magic_number
    header += version.to_bytes(1)
    header += encoding.to_bytes(1)
    header += framerate.to_bytes(1)
    header += width.to_bytes(1)
    header += height.to_bytes(1)
    
    return header


def main():
    print(f"Extracting frames from {video_file}... This may take a while...")
    framerate = extract_frames()

    # Reorder frames to follow the numerical order (2.png < 10.png)
    files = os.listdir(frames_destination_dir)
    files.sort(key=lambda x: int(x.split(".")[0]))

    conversion_fn = None
    color = False
    if ENCODING == ENCODINGS["1bit-grayscale"]:
        conversion_fn = convert_frame_1bit
    elif ENCODING == ENCODINGS["2bit-grayscale"]:
        conversion_fn = convert_frame_2bit
    elif ENCODING == ENCODINGS["4bit-grayscale"]:
        conversion_fn = convert_frame_4bit
    elif ENCODING == ENCODINGS["8bit-rgb332"]:
        conversion_fn = convert_frame_8bit_rgb332
        color = True
    elif ENCODING == ENCODINGS["16bit-rgb565"]:
        conversion_fn = convert_frame_16bit_rgb565
        color = True
    else:
        raise ValueError("Encoding identifier is invalid")

    header = make_header(
        ENCODING,
        IMAGE_SIZE[0],
        IMAGE_SIZE[1],
        max(1, min(255, round(framerate / frame_step))),
    )
    total = len(files)

    print("Converting frames to binary...")

    with open(output_file, "wb") as f:
        f.write(header)

        for idx, frame_path in enumerate(files):
            frame = read_frame(frames_destination_dir + "/" + frame_path, color)
            f.write(conversion_fn(frame))

            print(f"\r{idx + 1}/{total}", end="", flush=True)

    print("\nDone!")


if __name__ == "__main__":
    main()
