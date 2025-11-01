import cv2
from ninja import NinjaAPI, File
from ninja.files import UploadedFile
from .models import Image
from django.core.files.base import ContentFile


api = NinjaAPI()


@api.get("/count_saved_images/")
def count_saved_images(request):
    return {"response": f"saved images count: {Image.objects.count()}"}


@api.post("/upload_image/")
def upload_image(request, file: File[UploadedFile]):
    print(f"File uploaded: {file.name}", flush=True)

    content = file.read()
    picture = Image()
    picture.image.save(file.name, ContentFile(content))

    # 画像処理
    if image_cv := cv2.imread(picture.image.path) is not None:
        return {"response": f"success to read image: {image_cv.shape}"}
    else:
        return {"response": "failed to read image"}
