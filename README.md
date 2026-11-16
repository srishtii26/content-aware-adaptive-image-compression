# 🚀 Content-Aware Image Compression Using DCT-Based Frequency Analysis and Edge-Preserving Adaptive Quantization

A MATLAB-based image compression system that combines Discrete Cosine Transform (DCT), frequency-domain analysis and Sobel edge detection to reduce image storage while maintaining visual quality.

The project implements and compares two image compression approaches:

- Standard DCT-Based Image Compression
- Adaptive DCT-Based Image Compression

The adaptive approach analyzes local image details and adjusts the number of retained frequency coefficients based on the complexity of different image regions.

---

## 🌟 Project Overview

Traditional image compression techniques apply similar compression strategies across different image regions. However, not every region contains the same amount of visual information.

Smooth regions generally contain fewer details, whereas edges, textures and complex regions contain more important visual information.

This project introduces a content-aware adaptive compression technique that uses edge detection to identify image complexity and dynamically adjust frequency coefficient retention.

The main objective is to achieve better storage efficiency while maintaining the important visual characteristics of the original image.

---

## 💡 Problem Statement

Conventional image compression techniques may remove important visual details when applying compression uniformly across an image.

This can result in:

- Loss of edge information.
- Reduced image clarity.
- Loss of fine textures.
- Unnecessary preservation of information in smooth regions.
- Difficulty balancing compression efficiency and image quality.

An adaptive compression approach is therefore needed to identify important image regions and adjust compression accordingly.

---

## 🎯 Proposed Solution

The proposed system uses DCT-based frequency analysis and Sobel edge detection to perform content-aware image compression.

The system:

- Accepts an RGB image as input.
- Performs frequency-domain analysis using FFT.
- Divides the image into 8×8 blocks.
- Applies DCT to transform spatial information into frequency coefficients.
- Uses Sobel edge detection to identify image details.
- Classifies blocks into high-detail, medium-detail and low-detail regions.
- Retains different numbers of frequency coefficients according to local image complexity.
- Applies quantization to reduce less significant frequency information.
- Reconstructs the image using inverse DCT.
- Evaluates the performance using image-quality and compression metrics.

---

## ✨ Features Implemented

### 🖼️ 1. Image Processing

- RGB Image Input
- Image Preprocessing
- 8×8 Block Division
- Frequency-Domain Analysis
- FFT-Based Frequency Spectrum Visualization

### 📊 2. Edge Detection

- Manual Sobel Edge Detection
- Edge Strength Map
- Local Edge Density Calculation
- Image Detail Analysis
- Edge-Based Block Classification

### 🔄 3. Standard DCT Compression

- Manual 8×8 DCT Implementation
- Frequency Coefficient Selection
- Quantization
- Inverse DCT Reconstruction
- Standard Compression Baseline

### 🧠 4. Adaptive DCT Compression

- Content-Aware Block Classification
- High-Detail Block Detection
- Medium-Detail Block Detection
- Low-Detail Block Detection
- Adaptive Frequency Coefficient Retention
- Edge-Aware Compression Strategy
- Adaptive Image Reconstruction

### 📈 5. Performance Evaluation

- Mean Squared Error (MSE)
- Peak Signal-to-Noise Ratio (PSNR)
- Structural Similarity Index (SSIM)
- Compression Ratio
- Compressed File Size
- Storage Space Saving
- Standard vs Adaptive Performance Comparison

### 🧪 6. Experimental Analysis

- Multiple Quality-Level Experiments
- Quality Levels: 20, 30, 40, 50, 60, 70 and 80
- Performance Comparison Graphs
- Compression Results Export
- Visual Reconstruction Comparison

### 🎨 7. Dashboard

- Original Image Display
- Frequency Spectrum Visualization
- Edge Detection Visualization
- Standard DCT Reconstruction
- Adaptive DCT Reconstruction
- Performance Comparison Table
- Adaptive Block Distribution
- Compression Statistics
- Image Quality Metrics

---

## ⚙️ Adaptive Compression Methodology

The adaptive algorithm analyzes local edge density to classify image blocks.

Each block is assigned to one of three categories:

| Block Category | Edge Density | Compression Strategy |
|---|---|---|
| High Detail | Above 0.08 | Retains more frequency coefficients |
| Medium Detail | 0.03–0.08 | Retains a moderate number of coefficients |
| Low Detail | 0.03 or below | Retains fewer frequency coefficients |

### How It Works

- **High-detail regions:** More frequency coefficients are retained to preserve important edges and textures.
- **Medium-detail regions:** A moderate number of coefficients are retained.
- **Low-detail regions:** Fewer coefficients are retained because these regions contain relatively less visual complexity.

This allows the compression strategy to adapt to the content of individual image blocks.

---

## 🔬 Working Methodology

The complete processing pipeline follows these steps:

```text
                INPUT RGB IMAGE
                       ↓
               IMAGE PREPROCESSING
                       ↓
              FREQUENCY ANALYSIS
                     (FFT)
                       ↓
                 8×8 BLOCKING
                       ↓
                      DCT
                       ↓
              SOBEL EDGE DETECTION
                       ↓
           ADAPTIVE BLOCK CLASSIFICATION
                       ↓
         ┌─────────────┼─────────────┐
         ↓             ↓             ↓
      HIGH          MEDIUM          LOW
     DETAIL         DETAIL         DETAIL
         ↓             ↓             ↓
    More coeff.    Moderate      Fewer coeff.
         └─────────────┼─────────────┘
                       ↓
                  QUANTIZATION
                       ↓
               COMPRESSED DATA
                       ↓
                  INVERSE DCT
                       ↓
             RECONSTRUCTED IMAGE
                       ↓
              QUALITY EVALUATION
                       ↓
             STANDARD vs ADAPTIVE
                  COMPARISON
```

---

## 📊 Experimental Results

The system was tested using the MATLAB sample image `peppers.png`.

### Input Image Information

| Parameter | Value |
|---|---|
| Image Dimensions | 512 × 384 pixels |
| Color Channels | 3 (RGB) |
| Total Pixels | 196,608 |
| Original File Size | 280.93 KB |
| Raw Image Size | 576 KB |

### Standard DCT vs Adaptive DCT

The following results were obtained at quality level 50.

| Performance Metric | Standard DCT | Adaptive DCT |
|---|---:|---:|
| Compressed File Size | 82.24 KB | **77.93 KB** |
| Compression Ratio | 3.42:1 | **3.61:1** |
| Space Saving | 70.73% | **72.26%** |
| MSE | 11.0525 | **10.9467** |
| PSNR | 37.70 dB | **37.74 dB** |
| SSIM | 0.9707 | **0.9708** |

### Adaptive Block Distribution

| Block Category | Number of Blocks |
|---|---:|
| High Detail | 503 |
| Medium Detail | 923 |
| Low Detail | 1646 |
| **Total Blocks** | **3072** |

### Key Observations

- Adaptive DCT generated a smaller compressed file.
- Compression ratio improved from 3.42:1 to 3.61:1.
- Storage space saving increased from 70.73% to 72.26%.
- PSNR improved slightly from 37.70 dB to 37.74 dB.
- MSE decreased from 11.0525 to 10.9467.
- Both approaches maintained comparable reconstructed image quality.

**Note:** The compressed file sizes refer to the actual MATLAB `.mat` compressed representations generated by the project. They are not standard JPEG bitstream sizes. SSIM values shown here are from the MATLAB dashboard's structural similarity calculation.

---

## 📈 Multiple Quality-Level Experiments

The project evaluates compression performance across seven different quality levels:

`20, 30, 40, 50, 60, 70, 80`

The experiments compare standard and adaptive compression in terms of:

- Compressed File Size
- Compression Ratio
- Storage Space Saving
- Mean Squared Error
- Peak Signal-to-Noise Ratio
- Structural Similarity Index

### Experimental Observations

The adaptive approach produced slightly smaller compressed files and slightly better PSNR and MSE values across the tested quality levels.

The experiments also demonstrate the relationship between compression quality, storage requirements and reconstructed image quality.

---

## 📸 Screenshots

<img width="1280" height="434" alt="WhatsApp Image 2026-11-16 at 20 38 46 (3)" src="https://github.com/user-attachments/assets/c4ce11bb-9dbf-421c-88bc-483eee50c683" />


<img width="1280" height="521" alt="WhatsApp Image 2026-11-16 at 20 38 46" src="https://github.com/user-attachments/assets/19ec45e6-4132-4b49-b409-21e9648f04c0" />


<img width="1280" height="673" alt="WhatsApp Image 2026-11-16 at 20 38 46 (1)" src="https://github.com/user-attachments/assets/328feb15-47f9-4c84-b99f-5300f8ebbb40" />


<img width="1280" height="727" alt="WhatsApp Image 2026-11-16 at 20 38 46 (2)" src="https://github.com/user-attachments/assets/f2feba58-c023-4a4c-b3fb-c199349a19ac" />



---

## 🛠️ Tech Stack

### Main Development Environment

- MATLAB R2024b

### Image Processing Techniques

- Discrete Cosine Transform (DCT)
- Fast Fourier Transform (FFT)
- Inverse DCT
- Sobel Edge Detection
- Frequency Coefficient Selection
- Image Quantization
- Adaptive Compression

### Programming Concepts

- Matrix Operations
- Block-Based Image Processing
- Frequency-Domain Transformation
- Numerical Computation
- Image Reconstruction

### Evaluation Techniques

- Mean Squared Error
- Peak Signal-to-Noise Ratio
- Structural Similarity Index
- Compression Ratio
- Storage Space Analysis

### Additional Web Dashboard

- Python
- Streamlit
- NumPy
- Pillow
- Matplotlib

---

## 📁 Project Structure

```text
content-aware-adaptive-image-compression/
│
├── src/
│   ├── frequencyAnalysis.m
│   ├── edgeDetection.m
│   ├── frequencyCompression.m
│   ├── adaptiveCompression.m
│   ├── compressionMetrics.m
│   ├── actualCompression.m
│   ├── actualAdaptiveCompression.m
│   ├── decompressImage.m
│   ├── decompressAdaptiveImage.m
│   ├── comparisonExperiment.m
│   └── finalComparison.m
│
├── test_images/
│   └── peppers.png
│
├── results/
│   ├── comparisonResults.mat
│   ├── visual_comparison_quality_50.png
│   ├── zoomed_comparison_quality_50.png
│   └── multi_quality/
│       ├── multiQualityResults.mat
│       ├── multiQualityResults.csv
│       └── Generated Graphs
│
├── experiments/
│   └── multiQualityExperiment.m
│
├── screenshots/
│   ├── main_dashboard.png
│   ├── original_image.png
│   ├── frequency_analysis.png
│   ├── edge_detection.png
│   ├── standard_dct.png
│   ├── adaptive_dct.png
│   ├── performance_comparison.png
│   ├── multi_quality_results.png
│   └── web_dashboard.png
│
├── compressionDashboard.m
├── main.m
├── app.py
├── requirements.txt
├── .gitignore
└── README.md
---

## ⚙️ Installation & Setup

### 1. Requirements

Install or configure:

- MATLAB R2024b
- Python (for the optional web dashboard)
- VS Code (optional)

### 2. Clone Repository

```bash
git clone https://github.com/srishtii26/content-aware-adaptive-image-compression.git
```

### 3. Navigate Into Project

```bash
cd content-aware-adaptive-image-compression
```

### 4. Open MATLAB

Open MATLAB and navigate to the downloaded project folder.

Alternatively, launch MATLAB from the terminal:

```bash
matlab
```

### 5. Configure MATLAB Project Path

In the MATLAB Command Window:

```matlab
addpath(fullfile(pwd,'src'));
```

### 6. Run the Main Program

```matlab
main
```

### 7. Launch the MATLAB Dashboard

```matlab
compressionDashboard
```

---

## 🧪 Running Individual Experiments

Run these commands from the MATLAB Command Window after navigating to the project directory and adding the `src` folder to the MATLAB path.

### Standard DCT Compression

```matlab
actualCompression('test_images/peppers.png',50,'results/standard_compressed.mat')
```

### Standard DCT Decompression

```matlab
[standardImage,standardMetrics] = decompressImage('results/standard_compressed.mat');
```

### Adaptive DCT Compression

```matlab
actualAdaptiveCompression('test_images/peppers.png',50,'results/adaptive_compressed.mat')
```

### Adaptive DCT Decompression

```matlab
[adaptiveImage,adaptiveMetrics] = decompressAdaptiveImage('results/adaptive_compressed.mat');
```

### Standard vs Adaptive Comparison

```matlab
finalComparison
```

### Multiple Quality-Level Experiment

```matlab
multiQualityExperiment
```

*Ensure that the function names, input arguments and output folders match your actual MATLAB files.*

---

## 🌐 Web Dashboard Setup

The project also includes an additional Streamlit-based dashboard for visualizing the compression process.

### 1. Install Dependencies

Open the VS Code PowerShell terminal inside the project folder:

```powershell
pip install -r requirements.txt
```

### 2. Run the Web Dashboard

```powershell
python -m streamlit run app.py
```

### 3. Open in Browser

```text
http://localhost:8501
```

The web dashboard provides image visualization, compression comparisons and performance metrics.

**Note:** The Streamlit dashboard is a separate Python implementation for visualization. Its estimated compression-size calculations should not be confused with the actual MATLAB `.mat` file-size measurements.

---

## 📌 Advantages

- Content-aware image compression.
- Preserves more frequency information in detailed regions.
- Applies stronger compression to smoother regions.
- Manual DCT implementation without depending on `dct2`.
- Supports RGB image processing.
- Provides standard and adaptive compression comparison.
- Evaluates image quality using multiple metrics.
- Supports multiple quality-level experiments.
- Provides visual and numerical performance analysis.
- Includes MATLAB and web-based dashboards.

---

## ⚠️ Limitations

- The current implementation uses fixed 8×8 image blocks.
- Adaptive classification depends on predefined edge-density thresholds.
- The compressed representation uses MATLAB `.mat` files rather than a standard JPEG-compatible bitstream.
- Compression performance may vary depending on image content.
- The current experimental evaluation uses a limited set of test images.

---

## 🚀 Future Scope

The project can be extended with the following improvements:

- JPEG Compression Comparison
- RGB to YCbCr Color-Space Conversion
- Region of Interest (ROI)-Based Compression
- Advanced Edge-Preservation Metrics
- Entropy Coding
- Automatic Quality-Level Selection
- Batch Image Compression
- Compression Time and Memory Analysis
- Improved Adaptive Quantization Techniques
- Support for Additional Image Formats

---

## 🧠 Learning Outcomes

Through this project, I gained practical experience in:

- Digital Image Processing
- Frequency-Domain Analysis
- Discrete Cosine Transform
- Fast Fourier Transform
- Edge Detection Techniques
- Matrix-Based Computation
- Image Compression and Reconstruction
- Adaptive Algorithm Design
- Image Quality Evaluation
- MATLAB Programming
- Performance Comparison
- Experimental Analysis

---

## 💼 Applications

The concepts implemented in this project are relevant to:

- Digital Image Storage
- Image Transmission
- Multimedia Systems
- Bandwidth Optimization
- Image Processing Applications
- Storage-Efficient Imaging Systems

---

## 📬 Feedback

Suggestions and feedback are always welcome!

Feel free to explore the project and share your thoughts.

---

## 👩‍💻 Developed By

**Srishti S Rao**

B.Tech – Electronics and Computer Engineering  
Artificial Intelligence and Machine Learning Specialization

Christ University (Deemed to be University)  
Bengaluru, India

📧 Email: [srishtisrao26@gmail.com](mailto:srishtisrao26@gmail.com)

💼 LinkedIn: [srishti-s-rao](https://linkedin.com/in/srishti-s-rao-b09189316)

💻 GitHub: [srishtii26](https://github.com/srishtii26)

⭐ If you find this project interesting, consider giving the repository a star!
