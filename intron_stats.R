# load packages
library(tidyverse)

# load intron data
danio_rerio_introns = read_csv('danio_rerio_introns.csv')

# get intron sizes
danio_rerio_intron_sizes = select(danio_rerio_introns, Length)
