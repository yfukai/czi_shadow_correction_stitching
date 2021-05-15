from glob import glob
from os import path

czi_files = glob(path.join("**","*.czi"),recursive=True)
czi_files = [f[:-4] for f in czi_files if path.isfile(f)]
output_directory = config["output_directory"]

rule all:
  input: 
#    expand("{czi_file}_analyzed.created", czi_file=czi_files)
#    expand("{czi_file}_analyzed/.calculate_background.done", czi_file=czi_files)
#    expand("{czi_file}_analyzed/.rescale_background.done", czi_file=czi_files)
#    expand("{czi_file}_analyzed/.rescale_images.done", czi_file=czi_files)
    expand("{czi_file}_analyzed/.calculate_stitching.done", czi_file=czi_files)

rule d_calculate_stitching:
  input:
    output_dir_created = "{czi_file}_analyzed/.rescale_images.done"
  output:
    touch("{czi_file}_analyzed/.calculate_stitching.done")
  threads:
    1
  script:
    "scripts/d_stitch_images.py"
 
rule c_rescale_images:
  input:
    filename = "{czi_file}.czi", 
    output_dir_created = "{czi_file}_analyzed/.rescale_background.done"
  output:
    touch("{czi_file}_analyzed/.rescale_images.done")
  threads:
    1
  script:
    "scripts/c_rescale_images.py"
 
rule b_rescale_background:
  input:
    output_dir_created = "{czi_file}_analyzed/.calculate_background.done"
  output:
    touch("{czi_file}_analyzed/.rescale_background.done")
  threads:
    1
  script:
    "scripts/b_rescale_background.py"
 
rule a_calculate_background:
  input:
    filename = "{czi_file}.czi", 
    output_dir_created = "{czi_file}_analyzed.created"
  output:
    touch("{czi_file}_analyzed/.calculate_background.done")
  threads:
    workflow.cores
  script:
    "scripts/a_calculate_background.py"
    
rule create_output_directories:
  input:
    "{czi_file}.czi"
  output:
    temp("{czi_file}_analyzed.created")
  run:
    output1=output[0].replace(".created","")
    output2=path.join(output_directory,output1)
    output3=path.dirname(output1)
#    print(output[0],output1,output2)
    shell("sync && mkdir -p {output2} && ln -sf {output2} {output3} && touch {output[0]}")
  
