# CSE 240D Final Project: RTL Implementation of Parametric, Non-Linear Activation Functions, Random Number Generation and Softmax

### Activation Functions Implemented:

1. **Sigmoid**
   - **Description**: Smooth S-shaped function commonly used in classification tasks.
   - **Implementations**: LUT-based, Piece-Wise Linear approximation, Polynomial Approximation.
   - **Range**: Input in Q3.5 format \([-4, 4)\), Output in Q0.8 format \([0, 1)\).

2. **Tanh**
   - **Description**: Hyperbolic tangent function, scales inputs to \([-1, 1]\).
   - **Implementations**:  LUT-based, Piece-Wise Linear approximation, Tanh using sigmoid Piecewise linear approximation
   - - **Range**: Input in Q3.5 format \([-4, 4)\), Output in Q1.7 format \([-1, 1)\).

3. **GELU (Gaussian Error Linear Unit)**
   - **Description**: Smooth approximation to ReLU for improved gradient flow in neural networks.
   - **Implementations**: LUT-based, Piecewise Linear Approximation, Gelu using Tanh(Tanh using sigmoid piecewise linear approximation).
   - **Range**: Input in Q3.5 format \([-4, 4)\), Output in Q3.5 format \([-4, 4)\).

4. **PReLU (Parametric ReLU)**
   - **Description**: Variant of ReLU with a learnable slope for negative inputs.
   - **Parameter**: \(\alpha\) is a tunable parameter (default: \(\alpha = 0.5\)).
   - **Implementations**: Shift and add for multiplication.
   - **Range**: Input in Q3.5 format \([-4, 4)\), Output in Q3.5 format \([-4, 4)\)

