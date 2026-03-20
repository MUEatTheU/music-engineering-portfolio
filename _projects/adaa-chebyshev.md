---
layout: project
title: "Antialiased Nonlinear Blackbox Model"
student_name: "Dr. Bennett"
student_slug: "Dr-Bennett"
category: "Research"
tags:
  - antialiasing
  - Volterra
  - DSP
short_blurb: "Anti-Derivative Anti-Aliasing for the Chebyshev Non-Linear Model"
thumbnail_image: "/assets/images/projects/adaa.jpg"
full_description: "There have been many techniques for modeling static memoryless non-linearities, with the Synchronized Sine-Sweep Method in combination with the Chebyshev Non-Linear Model proving to be one of the most effective. Unlike other similar approaches such as the Simplified Volterra and Legendre models, the Chebyshev model offers a unique advantage due to its close relation to certain cosine identities, allowing for the extreme simplification of the necessary calculations. However, when modeling any non-linear system that introduces harmonics and high-frequency content, aliasing emerges as a significant and problematic issue. To combat this, a method known as Anti-Derivative Anti-Aliasing (ADAA) was developed, proving highly effective in lowering the energy of aliasing frequencies in other non-linear systems. This research explores the application ADAA specifically to the Chebyshev model, and defines general equations for the modified approach. It was found that the implementation of ADAA successfully reduced aliasing in two variations of the model, providing an average attenuation of 16.25 dB when measuring the first 16 aliasing harmonics of a wave-shaped 5kHz test-tone. Overall, the adapted method serves as an optimal way to emulate a non-linear system while minimizing the drawbacks of digital artifacts."
repo_url: "https://gitlab.com/dr_bennett/chebyshev-adaa-model"
demo_url: "https://aes2.org/publications/elibrary-page/?id=22918"
featured: true
publish_date: 2026-02-20
---
