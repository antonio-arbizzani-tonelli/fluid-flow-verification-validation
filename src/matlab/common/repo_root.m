function rootDir = repo_root()
%REPO_ROOT Return the absolute path of the repository root.

commonDir = fileparts(mfilename('fullpath'));
rootDir = fileparts(fileparts(fileparts(commonDir)));

end
