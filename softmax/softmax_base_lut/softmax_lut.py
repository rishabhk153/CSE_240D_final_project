import numpy as np
import matplotlib.pyplot as plt
# Generate the LUTs
def generate_exponent_lut():
    # 1 sign 3 int 12 frac
    # Step size for LSB is 1/16
    delta = 1 / (2**12)

    # MSB LUT: 4-bit MSB values (0-15), representing `e^(0 to 15)`
    msb_lut = [round(np.exp(i/(2**4))) for i in range(256)]

    # LSB LUT: 4-bit LSB values (0-15), representing `e^(j * delta)` for j in [0, 15]
    lsb_lut = [round(np.exp(j * delta)) for j in range(256)]

    return msb_lut, lsb_lut

# Compute the exponential using LUTs
def compute_exponent(input_value, msb_lut, lsb_lut):
    # Split the input into MSB and LSB
    msb = (input_value >> 8) & 0xFF  # Top 8 bits
    lsb = input_value & 0xFF         # Bottom 8 bits

    # Lookup values from LUTs

    print(hex(msb),hex(lsb))
    exp_msb = msb_lut[msb]
    exp_lsb = lsb_lut[lsb]
    print(exp_msb,exp_lsb)
    # Multiply to approximate the exponent
    result = int(exp_msb,16) * int(exp_lsb,16)
    return result

# Main
lsb_fraction_bit=12
lsb_scale=2**lsb_fraction_bit

msb_lut, lsb_lut = generate_exponent_lut()
print("herehereher\n",msb_lut,"\n", lsb_lut)
msb_lut_H=[hex((i*(2**4)))[2:].zfill(4) for i in msb_lut]
lsb_lut_H=[hex((i*lsb_scale))[2:].zfill(4) for i in lsb_lut]
print(msb_lut_H)
#msb_lut_H.reverse()
#print("".join(msb_lut_H))
#lsb_lut_H.reverse()
#print("".join(lsb_lut_H))

# Example: Test for an 8-bit input (e.g., 100 in decimal)
input_value = 100  # 8-bit value
input = (np.random.rand(100,1)*(2**15)).astype('float16')
#input = np.array([[4000]])
print(input)
#result = compute_exponent(input_value, msb_lut, lsb_lut)
sum_ideal=0
sum_estimate=0
exp_ideal=[]
exp_estimate=[]
X_list=[]
for x in range(input.shape[0]):
    i=int(input[x][0])
    X_list.append(i/(2**12))
    print(f"Input Value HEX: {hex(i)}")
    result = compute_exponent(i, msb_lut_H, lsb_lut_H)
    result=result/lsb_scale/(2**4)
    print(f"Input Value: {i}")
    print(f"e^{i /lsb_scale:.4f} ≈ {result:.5f}")
    print(f"e^{i /lsb_scale:.4f} = {np.exp(i/lsb_scale):.5f}")
    sum_ideal+=np.exp(i/lsb_scale)
    sum_estimate+=result
    exp_ideal.append(np.exp(i/lsb_scale))
    exp_estimate.append(result)

print(sum_ideal,sum_estimate)
print(exp_ideal,exp_estimate)
softmax_ideal=[i/sum_ideal for i in exp_ideal]
softmax_est=[i/sum_estimate for i in exp_estimate]
print(softmax_ideal,"\n",softmax_est)
Y_list=softmax_ideal
hard_o=softmax_est
sorted_pairs = sorted(zip(X_list, Y_list))
X_list_s1, Y_list = zip(*sorted_pairs)
sorted_pairs = sorted(zip(X_list, hard_o))
X_list_s2, Y_list2 = zip(*sorted_pairs)

Y2_minus_Y1 = [abs(Y_list2[i]-Y_list[i]) for i in range(0,len(Y_list2))]

print(Y2_minus_Y1)
print(sum(Y2_minus_Y1)/len(Y2_minus_Y1))
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 8), sharex=True)
ax1.plot(X_list_s1, Y_list,label="Ideal Softmax",linestyle='-', marker='o')  # Use a marker to make the points visible
ax1.plot(X_list_s2, Y_list2,label="Hardware Result",linestyle='--', marker='x')  # Use a marker to make the points visible
ax1.set_title("Ideal Softmax VS Hardware Result")  # Title of the graph
#ax1.set_xlabel("X-axis Label")  # Label for the x-axis
#ax1.set_ylabel("Y-axis Label")  # Label for the y-axis
ax1.legend()
ax1.grid(True)  # Add gridlines for better readability
#ax1.show()  # Display the plot

# Plot the differences on the second subplot
ax2.plot(X_list_s1, Y2_minus_Y1 , label="Absolute Error", color='green', marker='s')
ax2.axhline(0, color='black', linewidth=0.8, linestyle='--')  # Add a baseline for reference
ax2.set_title("Absolute Error")
ax2.set_xlabel("Input")
ax2.set_ylabel("Difference")
ax2.legend()
ax2.grid(True)

# Adjust layout and show the plot
plt.tight_layout()
plt.show()
#print(int(0.01,16))


## 0000(4).0000000000000(12)