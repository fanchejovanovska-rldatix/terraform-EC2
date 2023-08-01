docker run --rm -it -v C:\Users\luke.powell\.aws:/root/.aws -v C:\Misc\Packer\:/workspace -w /workspace --entrypoint bash packer-builder:latest
pause