import cv2

cap = cv2.VideoCapture("test_video.avi")

while True:
    ret, frame = cap.read()

    if ret:
        cv2.imshow("video", frame)
    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()
