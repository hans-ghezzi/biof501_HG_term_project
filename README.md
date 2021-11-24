# <img src="./man/figures/Tropini_Lab_logo.png" align="right" height="150" /> Snakemake workflow: *in vivo* bacterial replication rates

### By: Hans Ghezzi - Tropini Lab

[![Snakemake](https://img.shields.io/badge/snakemake-≥6.10.0-brightgreen.svg)](https://snakemake.github.io)

***

# Project 

This workflow calculates *in vivo* bacterial replication rates from single time point metagenomics sequencing with [iRep](https://github.com/christophertbrown/iRep).

## Overview

The human gut is inhabited by a diverse community of microorganisms, collectively known as the microbiota, which is deeply connected to human health [[1]](#1). In disease, the gut ecosystem experiences drastic perturbations to its physical environment, which can impact both the host and the microbial communities that inhabit it [[2]](#2)[[3]](#3)[[4]](#4). Specifically, physical perturbations can impede bacterial growth by disrupting the specific environmental conditions required by bacteria to survive [[2]](#2). A common perturbation to the gut environment is due to malabsorption, which leads to an increase in gut osmolality, or the number of non-absorbed particles in intestinal contents. Malabsorption is caused by laxative use, food intolerances or inflammatory bowel disease [[2]](#2)[[5]](#5). Gut osmolality increases induce osmotic diarrhea by causing water to exit cells to balance the disrupted osmotic potential [[6]](#6). This also affects the gut microbial communities in a species dependent manner [[2]](#2)[[7]](#7). 

Understanding the impact of the osmolality on the gut microbiota is a necessary step towards developing microbiota-aware precision medicine. This can be achieved by leveraging *in vitro* and *in vivo* models to evaluate gut microbial responses to increased osmotic stress, which will help identify strains that can tolerate and ameliorate malabsorption. Specifically, bacterial abundance and growth rate can be measured as indicators of bacterial responses to osmotic stress. *In vitro* bacteria abundance and growth rate under different osmolalities can be rapidly and easily calculate via simple plate reader experiments. However, assessing these measures *in vivo* is more challenging, as it requires metagenomics sequencing and computational expertise. Here, we introduce a snakemake workflow to calculate bacterial replication rates using the tool [iRep](https://github.com/christophertbrown/iRep) [[8]](#8) from single time point metagenomics sequencing


## References
<a id="1">[1]</a>
Kho ZY, Lal SK. 2018. The Human Gut Microbiome – A Potential Controller of Wellness and Disease. Front Microbiol.

<a id="2">[2]</a>
Tropini C, Moss EL, Merrill BD, Ng KM, Higginbottom SK, Casavant EP, Gonzalez CG, Fremin B, Bouley DM, Elias JE, Bhatt AS, Huang KC, Sonnenburg JL. 2018. Transient Osmotic Perturbation Causes Long-Term Alteration to the Gut Microbiota. Cell 173:1742-1754.e17.

<a id="3">[3]</a>
Wood JM. 2015. Bacterial responses to osmotic challenges. J Gen Physiol 145:381–388.

<a id="4">[4]</a>
Cesar S, Anjur-Dietrich M, Yu B, Li E, Rojas E, Neff N, Cooper TF, Huang KC. 2020. Bacterial Evolution in High-Osmolarity Environments. mBio 11.

<a id="5">[5]</a>
Juckett G, Trivedi R. 2011. Evaluation of chronic diarrhea. Am Fam Physician 84:1119– 1126.

<a id="6">[6]</a>
Woods TA. 1990. Diarrhea, p. . In Walker, HK, Hall, WD, Hurst, JW (eds.), Clinical Methods: The History, Physical, and Laboratory Examinations, 3rd ed. Butterworths, Boston.

<a id="7">[7]</a>
Gorkiewicz G, Thallinger GG, Trajanoski S, Lackner S, Stocker G, Hinterleitner T, Gülly C, Högenauer C. 2013. Alterations in the Colonic Microbiota in Response to Osmotic Diarrhea. PLoS ONE 8:e55817.

<a id="8">[8]</a>
Brown, C. T., Olm, M. R., Thomas, B. C., & Banfield, J. F. (2016). Measurement of bacterial replication rates in microbial communities. Nature biotechnology, 34(12), 1256–1263. https://doi.org/10.1038/nbt.3704
