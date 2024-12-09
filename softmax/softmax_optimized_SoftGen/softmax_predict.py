import numpy as np
import argparse
import os
import matplotlib.pyplot as plt
parser = argparse.ArgumentParser();
parser.add_argument('sets', type = int,
		    help = 'the number of sequence into softmax')
parser.add_argument('pins', type = int,
                    help = 'The number of pins in softmax')

args = parser.parse_args()
n = args.pins
sets = args.sets
#Input array of type float16 populated with random values
print("--------input value in decimal is:------------")

input = np.array([[0.293*8], 
                  [0.749*8], 
                  [0.2147*8], 
                  [0.4949*8]], dtype='float16')
input = (np.random.rand(n*sets,1)*8).astype('float16')
input_fix16 = input*(2**12)
input_fix16 = input_fix16.astype(np.int16)
print(input)
print(input_fix16)
print("----------input value in hex is:--------------")
with open("mem.txt", "w") as my_file:
    my_file.write("0000000000000000\n")
    my_file.write("0000000000000000\n")
    for x in range(input.shape[0]):
        H = hex(input[x][0].view('H'))[2:].zfill(4)
        H_fix16 = hex(input_fix16[x][0].view('H'))[2:].zfill(4)

        if(x%n == 0 and x is not 0):
            print("")
            my_file.write("\n")

        #print(H, end= "")
        #print("\n")
        input_h_r=str(H_fix16)
        my_file.write(input_h_r)

        print(H_fix16, end= "")
    my_file.write("\n0000000000000000\n")
    my_file.write("0000000000000000\n")
    my_file.write("0000000000000000\n")
    my_file.write("0000000000000000\n")
    my_file.write("0000000000000000\n")
    my_file.write("0000000000000000\n")
print("")
print("----------MAX value is:-----------------------")
MAX = np.max(input)
MAX_fix16 = np.max(input_fix16)

print(MAX)
print(hex(MAX.view('H'))[2:].zfill(4))
print(hex(MAX_fix16.view('H'))[2:].zfill(4))
#Calculate e^x
print("-----normalized value after subtraction is:---")
input = np.subtract(input, MAX)
sub_r = (input*(2**12)).astype(np.int16)

for x in range(input.shape[0]):
  H = hex(input[x][0].view('H'))[2:].zfill(4)
  H_fix16 = hex(sub_r[x][0].view('H'))[2:].zfill(4)
  print(H)
  print("fix16:", H_fix16)

print(input)
#exp_array = np.exp(input)
#print(exp_array)
print("---------exponential value results:-----------")
exp = np.exp(input)
print(exp)
exp_fix16=(exp*(2**12)).astype(np.int16)
print(exp_fix16)
for x in range(exp.shape[0]):
  H = hex(exp[x][0].view('H'))[2:].zfill(4)
  H_fix16 = hex(exp_fix16[x][0].view('H'))[2:].zfill(4)

  print(H)
  print("fix16:", H_fix16)

print("------------summing results are:--------------")
sum = np.sum(exp)
print(sum)
print(sum*(2**12))
print(hex(sum.view('H'))[2:].zfill(4))

print("------------log results are:------------------")
log = np.log(sum)
print(log)
print(log*(2**12))
log_fix=(log*(2**12)).astype(np.int16)
print(hex(log.view('H'))[2:].zfill(4))
print(hex(log_fix.view('H'))[2:].zfill(4))
print(bin(log.view('H'))[2:].zfill(16))
print(bin(log_fix.view('H'))[2:].zfill(16))
print("------second stage results are::--------------")
sub2 = np.subtract(input, log)
for x in range(sub2.shape[0]):
  H = hex(sub2[x][0].view('H'))[2:].zfill(4)
  print(H)
  print(sub2[x][0]*(2**12))

print("------final results are::--------------")
exp2 = np.exp(sub2)
X_list=[]
Y_list=[]
with open("result_decimal.txt", "w") as my_file:
    for x in range(exp2.shape[0]):
        H = hex(exp2[x][0].view('H'))[2:].zfill(4)
        print(input[x][0])
        X_list.append(input[x][0])
        #print(H)
        out_r=str(exp2[x][0]*(2**12))+"\n"
        my_file.write(out_r)
        print("decial:",exp2[x][0]*(2**12))
        Y_list.append(exp2[x][0])


os.system("iverilog -f filelist -o compiled ; vvp compiled")
# hardware output
with open("result_decimal.txt", "r") as my_file:
	Y_list = [i.strip("\n").strip() for i in my_file]
	Y_list =[1/(2**12) if x==4095 else float(x)/(2**12) for x in Y_list]
with open("output.txt", "r") as my_file:
	hard_o = [int(i.strip("\n").strip()) for i in my_file]
	hard_o=[1/(2**12) if x==4095 else x/(2**12) for x in hard_o]
	print(hard_o)
# Plot the graph
print(Y_list)
sorted_pairs = sorted(zip(X_list, Y_list))
X_list_s1, Y_list = zip(*sorted_pairs)
sorted_pairs = sorted(zip(X_list, hard_o))
X_list_s2, Y_list2 = zip(*sorted_pairs)

Y2_minus_Y1 = [abs(Y_list2[i]-Y_list[i]) for i in range(0,len(Y_list2))]

print(Y2_minus_Y1)
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
