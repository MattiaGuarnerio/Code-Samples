Dear Damian,

Greetings. The order of the scripts' execution is as follows:

1) Data Collection
	a) Data Collection
	b) House Summary Collection
	c) Senate Summary Collection
	d) Metadata Collection
	e) Metadata Diagnostics

2) Data Cleaning (1)
	a) Data Cleaning

3) Supervised Machine Learning
	a) Data Labelling
	b) Classic Supervised Machine Learning
	c) LEGAL-BERT Fine-Tuning
	d) Base BERT Fine-Tuning
	e) Downstream Task

4) Data Cleaning (2)
	b) Metadata Cleaning

5) Data Analysis
	a) Data Analysis

The reasons why I organised the scripts in a separate fashion are twofold:
1) I wanted to render and replicate the real research process as closely as possible.
2) I prioritised the understandability of the single scripts and the overall procedure.

There are some key additional aspects that I must explicit:

1) The Summary Collection was originally devised as a single script, but I wanted to make sure that you could read the output.
Therefore, I splitted it into two distinct scripts, to avoid having to execute the whole document (around 30 hours) in order to keep the output annotations.

2) The Metadata Collection script is apparently not compiled.
This is because I had to execute it on the Microsoft Azure ML cloud computing platform, in order to optimise the times of the metadata collection procedure.
When the analyst loses connection, or closes the browser window, all output is lost.
I made sure that you could get the output of the analogous files for Summary Collection, so to provide hard proof of completion.
If you are unsatisfied with this choice, please contact me as soon as possible so that I can show you how the script runs.

3) The LEGAL-BERT Fine-Tuning script is compiled in its outputs only, because when I saved it I probably lost connection with Google CoLab's servers.
I realised this only when the Downstream Task script was already running.
Therefore, I avoided re-compiling it to abide by the interpretations and choices I had already made based on the existing outputs.
In any case, the script is very similar to the base BERT Fine-Tuning script, so you can refer to the latter as a solid ground for interpretation.
If you are unsatisfied with this choice, please contact me as soon as possible so that I can show you how the script runs.

For a final time, I thank you for your support, and understanding. The course was splendid, and I greatly appreciated the effort you put in organising it.

Best wishes,
Mattia Guarnerio