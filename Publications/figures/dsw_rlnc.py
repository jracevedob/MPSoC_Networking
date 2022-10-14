###




# Library import
from matplotlib import rc
import numpy as np 
import matplotlib.pyplot as plt

# Change the default font family
rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
rc('text', usetex=True)

# Input source data
processing_data =  [0.8, 0.87,  0.95, 0.93]
delay_data  =  [ 0.2,  1,  5, 4]

labels = ['RPT', 'CRLNC-1', 'CRLNC-2', 'DSW-RLNC']

# Setting the positions and width for the bars
pos = list(range(len(delay_data))) 
width = 0.15 # the width of a bar

# Plotting the bars
fig, ax = plt.subplots(figsize=(10,6))

# Create second y-axis
ax2 = ax.twinx()

plt.bar([p + width*1 for p in pos], processing_data, width,
                 alpha=0.5,
                 color='red',
                 hatch='//', # this one defines the fill pattern
                 label=labels[0])

ax2.bar([p + width*2 for p in pos], delay_data, width,
                 alpha=0.5,
                 color='lime',
                 hatch='*',
                 label=labels[1])




# Setting axis labels and ticks
ax.set_ylabel('Average Packet Success Rate (\%)', fontsize=14)
# Secondary y-axis label
ax2.set_ylabel('Average Delay [Slots]',fontsize=14)
ax.set_xlabel('Coding scheme', fontsize=14)
ax.set_title('')
ax.set_xticks([p + 1.5 * width for p in pos])
ax.set_xticklabels(labels)

# Scaling x and y-axis
plt.xlim(min(pos)-width, max(pos)+width*5)
#plt.ylim([0, max(delay_data + processing_data) * 1.5])
#plt.ylim([0, 6])
ax.set_ylim([0, 1])
ax2.set_ylim([0, 6])

# Adding the legend and showing the plot
plt.legend(['Sucess Rate', 'Delay'], loc='upper right')
plt.grid()
plt.show()

# Export parameters
