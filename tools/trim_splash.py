import cv2
import shutil

source = r"mobile/assets/videos/splash.mp4"
temporary = r"mobile/assets/videos/splash_fixed.mp4"
capture = cv2.VideoCapture(source)
width = int(capture.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(capture.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = capture.get(cv2.CAP_PROP_FPS) or 24
writer = cv2.VideoWriter(temporary, cv2.VideoWriter_fourcc(*"mp4v"), fps, (width, height))
frames = 0
while frames < 108:
    ok, frame = capture.read()
    if not ok:
        break
    writer.write(frame)
    frames += 1
writer.release()
capture.release()
shutil.move(temporary, source)
print(f"trimmed to {frames} frames ({frames / fps:.2f}s)")
