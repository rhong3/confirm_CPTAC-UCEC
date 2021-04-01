"""
Tile svs/scn files

Created on 11/01/2018

@author: RH
"""

import time
import matplotlib
import os
import shutil
import pandas as pd
matplotlib.use('Agg')
import Slicer
import staintools


# Get all images in the root directory
def image_ids_in(root_dir, ignore=['.DS_Store', 'dict.csv']):
    ids = []
    for id in os.listdir(root_dir):
        if id in ignore:
            print('Skipping ID:', id)
        elif '.svs' in id:
            dirname = id.split('.')[0][:-3]
            sldnum = id.split('-')[-1].split('.')[0]
            ids.append((id, dirname, sldnum))
        else:
            continue
    return ids


# cut; each level is 2 times difference (20x, 10x, 5x)
def cut():
    # load standard image for normalization
    std = staintools.read_image("../colorstandard.png")
    std = staintools.LuminosityStandardizer.standardize(std)
    ref = pd.read_csv('../Slides.csv', header=0)
    refls = ref['Slide_ID'].tolist()
    # cut tiles with coordinates in the name (exclude white)
    start_time = time.time()
    CPTAClist = image_ids_in('../images/CPTAC-confirmatory/')

    # CPTAC
    for i in CPTAClist:
        if i[0].split(".")[0] in refls:
            try:
                os.mkdir("../tiles/{}".format(i[1]))
            except(FileExistsError):
                pass
            for m in range(4):
                if m == 0:
                    tff = 1
                    level = 0
                elif m == 1:
                    tff = 2
                    level = 0
                elif m == 2:
                    tff = 1
                    level = 1
                elif m == 3:
                    tff = 2
                    level = 1
                otdir = "../tiles/{}/level{}".format(i[1], str(m))
                try:
                    os.mkdir(otdir)
                except(FileExistsError):
                    pass
                try:
                    n_x, n_y, raw_img, ct = Slicer.tile(image_file='CPTAC-confirmatory/'+i[0], outdir=otdir,
                                                                    level=level, std_img=std, dp=i[2], ft=tff)
                except Exception as err:
                    print(i)
                    print(type(err))
                    print(err)
                    pass

                if len(os.listdir(otdir)) < 2:
                    shutil.rmtree(otdir, ignore_errors=True)

    print("--- %s seconds ---" % (time.time() - start_time))

    # # Time measure tool
    # start_time = time.time()
    # print("--- %s seconds ---" % (time.time() - start_time))


# Run as main
if __name__ == "__main__":
    if not os.path.isdir('../tiles'):
        os.mkdir('../tiles')
    cut()

