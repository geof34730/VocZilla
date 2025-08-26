# depuis la racine de ton projet Flutter
mkdir -p assets/asr_en

curl -L -o assets/asr_en/tokens.txt \
  'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-21/resolve/main/tokens.txt'

curl -L -o assets/asr_en/encoder-epoch-99-avg-1.int8.onnx \
  'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-21/resolve/main/encoder-epoch-99-avg-1.int8.onnx'

curl -L -o assets/asr_en/decoder-epoch-99-avg-1.int8.onnx \
  'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-21/resolve/main/decoder-epoch-99-avg-1.int8.onnx'

curl -L -o assets/asr_en/joiner-epoch-99-avg-1.int8.onnx \
  'https://huggingface.co/csukuangfj/sherpa-onnx-streaming-zipformer-en-2023-06-21/resolve/main/joiner-epoch-99-avg-1.int8.onnx'
