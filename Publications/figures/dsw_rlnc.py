###




# Library import
from matplotlib import rc
from matplotlib.pyplot import figure
import numpy as np 
import matplotlib.pyplot as plt

# Change the default font family
rc('font', **{'family': 'serif', 'serif': ['Computer Modern']})
rc('text', usetex=True)

# Input source data
labels = ['RPT', 'CRLNC-1', 'CRLNC-2', 'DSW-RLNC']
success_data =  [80, 87, 95, 93]
delay_data  =  [ 0.2, 1, 5, 4]

# Set figure size
#figure(figsize=(8, 6), dpi=80)


# Setting the positions and width for the bars
pos = np.arange(len(labels))
width = 0.15 # the width of a bar

# Plotting the bars
fig, ax = plt.subplots(figsize=(10,6))

# Twin object for two different y-axis on the sample plot
ax2=ax.twinx()

#plt.bar([p + width*1 for p in pos], success_data, width,
ax.bar(pos+width, success_data, width,
                 alpha=0.5,
                 color='blue',
                 hatch='xxx')

#plt.bar([p + width*2 for p in pos], delay_data, width,
ax2.bar(pos+width*2, delay_data, width,
                 alpha=0.5,
                 color='lime',
                 hatch='*')


# Setting axis labels and ticks
ax.set_ylabel('Average Packet Success Rate (\%)', fontsize=14)
ax2.set_ylabel('Average Delay [Slots]', fontsize=14)
ax.set_xlabel('Coding scheme', fontsize=14)
ax.set_title('')
ax.set_xticks([p + 1.5 * width for p in pos])
ax.set_xticklabels(labels)

# Scaling x and y-axis
plt.xlim(min(pos)-width, max(pos)+width*5)
ax.set_ylim([0, 100])
ax2.set_ylim([0, 10])

# Adding the legend and showing the plot
#plt.legend(loc='upper right')
fig.legend([ax.bar, ax2.bar],     # The line objects
           labels=['Success Rate','Delay'],   # The labels for each line
           loc="top right",   # Position of legend
           borderaxespad=0.1,    # Small spacing around legend box
           title=""  # Title for the legend
           )

# Export parameters
#plt.figure(figsize=(8, 6), dpi=80)
plt.savefig('figure_result.png', dpi=1200)

plt.grid()
plt.show()


