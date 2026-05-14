import torch
import torch.nn as nn
import torch.nn.functional as F
import time

# 1. Define a tiny CNN 
class TinyNet(nn.Module):
    def __init__(self):
        super(TinyNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, kernel_size=3, padding=1)
        self.fc = nn.Linear(16 * 32 * 32, 10)

    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = x.view(x.size(0), -1)
        x = self.fc(x)
        return x

# 2. Setup Device
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using GPU: {torch.cuda.get_device_name(0)}")

# 3. Initialize Model and Data
model = TinyNet().to(device)
dummy_input = torch.randn(64, 3, 32, 32).to(device) # Batch of 64 images

# 4. Inference
print("Running forward pass...")
start_time = time.time()
with torch.no_grad():
    output = model(dummy_input)
end_time = time.time()

print(f"Success! Output shape: {output.shape}")
print(f"Memory used on HBM3: {torch.cuda.memory_reserved(0) / 1024**2:.2f} MB")
print(f"Execution time: {end_time - start_time:.4f} seconds")