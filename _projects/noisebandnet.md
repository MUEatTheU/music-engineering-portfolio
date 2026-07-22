---
layout: project
title: "NoiseBandNet"
student_name: "Tom Collins"
student_slug: "tom-collins"
category: "Research"
tags:
  - ml
  - ai
  - dsp
course: ""
short_blurb: |-
  Lightweight deep neural networks for audio synthesis, with creative tone-transfer applications
thumbnail_image: "/assets/images/projects/nbn-arch-thumb.png"
full_description: |-
  This project explores the training of neural networks to synthesize audio that reconstructs inputs, based entirely on features (such as amplitude and spectral centroid) extracted from those inputs. See the image for the network architecture, which we call NoiseBandNet.
  
  NoiseBandNet is an example of differentiable digital signal processing (DDSP). In classical DSP, you have oscillators, filters, reverbs, etc. with parameters you design or estimate. In DDSP, these parameters are embedded inside a gradient-based learning loop. The first paper to explore this is by Engel et al. (2020), but it is restricted to pitched sounds, where the concept of F0 or fundamental frequency makes sense. Many sounds are partly or wholly unpitched, however, and F0 is less meaningful.
  
  In research with grad student Adrián Barahona-Ríos (Barahona-Ríos & Collins, 2024), we developed NoiseBandNet to explore more lightweight network architectures and training procedures than DDSP, and to use spectral centroid instead of F0, expanding the scope of Engel et al.'s (2020) work.
  
  For me, the most exciting application of the resulting neural network is tone transfer or timbre transfer: this is when one sound file is re-rendered according to some properties of another sound file or sound world. We used it in the 2023 submission to the International AI Song Contest, where we worked with UK RnB artist Kemi Sulola. In one part of the song (3'03"), we transfer Kemi's melody line into a glitchy Romantic string ensemble sample, over a DnB beat. Check out the examples here:
  https://vtgo.onrender.com/
  https://open.spotify.com/track/2OlqfwEE7eZB7xAt25gJ42
  
  
  References
  Barahona-Ríos, A., & Collins, T. (2024). Noisebandnet: Controllable time-varying neural synthesis of sound effects using filterbanks. IEEE/ACM Transactions on Audio, Speech, and Language Processing, 32, 1573-1585.
  
  Engel, J., Gu, C., & Roberts, A. (2020). DDSP: Differentiable Digital Signal Processing. In International Conference on Learning Representations.
repo_url: "https://github.com/adrianbarahona/noisebandnet"
demo_url: "https://adrianbarahonarios.com/noisebandnet/"
publish_date: 2026-07-22
---

<!--
Generated from issue: https://github.com/MUEatTheU/music-engineering-portfolio/issues/5

Maintainer image checklist:
- Download the issue attachments.
- Add them to assets/images/projects/.
- Confirm thumbnail_image points to the correct file.
- Add any inline image Markdown to full_description if needed.

Submitted image notes:
<img width="1600" height="900" alt="Image" src="https://github.com/user-attachments/assets/c64017c1-e795-4b70-94eb-35e039d8ccb7" />
<img width="2730" height="663" alt="Image" src="https://github.com/user-attachments/assets/db038376-08d8-47af-83c1-4fa80954c4b2" />

Submitted image placement notes:
nbn-arch.png should appear after the first paragraph.
-->
