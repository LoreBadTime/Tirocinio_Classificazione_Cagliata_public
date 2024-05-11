try:
    import numpy as np
    import scipy
    from scipy.sparse import issparse
    from scipy.special import digamma
    from scipy.spatial import KDTree
    from sklearn.neighbors import NearestNeighbors
    import sklearn.feature_selection
    from numbers import Integral
    import os
except:
    print("missing libraries(scipy,numpy,sklearn), skipping mutual information equivalence check test with scipy")
    exit(0)



# script usato per testare gli input e gli output della feature extraction 
# reimplementata in matlab
# le features vanno salvate in un file a.mat, variabile nome features
# i labels in b.mat, con nome variabile Y

file_path = __file__.split("test1")[0] + "a"
mat = scipy.io.loadmat(file_path)
a = mat['features']
os.remove(file_path+".mat")

file_path = __file__.split("test1")[0] + "b"
mat = scipy.io.loadmat(file_path)

b = mat['Y']

b = np.array([ x[0]  for x in b])
os.remove(file_path+".mat")

a = sklearn.feature_selection.mutual_info_classif(a,b,n_neighbors=3)
nscores = 10
with open("mutual_info_python.txt","w+") as f:
    f.writelines([str(x) for x in a])
print("Last "+ str(nscores) + " scores :" +str(a[-nscores:]))

