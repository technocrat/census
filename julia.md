# Installing Julia on macOS and Ubuntu

## macOS Installation

1. **Using Homebrew**:
~~~<pre>bash

   brew install julia
</pre>~~~


2. **Direct Download**:
   - Visit the official Julia website: https://julialang.org/downloads/
   - Download the macOS .dmg file for your architecture (Intel or Apple Silicon)
   - Open the .dmg file and drag the Julia app to your Applications folder
   - For command-line access, create a symlink:
~~~
</pre>
     sudo ln -s /Applications/Julia-x.y.app/Contents/Resources/julia/bin/julia /usr/local/bin/julia
</pre>
~~~


3. **Using juliaup (Version Manager)**:
~~~<pre>bash

   curl -fsSL https://install.julialang.org | sh
</pre>~~~


## Ubuntu Installation

1. **Using apt (from default repositories)**:
~~~
<pre>bash

   sudo apt update
   sudo apt install julia
</pre>
~~~

   Note: This might not install the latest version

2. **Using the official Julia PPA**:
~~~
<pre>bash

   sudo add-apt-repository ppa:julia-team/julia
   sudo apt update
   sudo apt install julia
</pre>~~~

3. **Direct Download**:
~~~<pre>bash

   # Download the latest Linux tarball
   wget https://julialang-s3.julialang.org/bin/linux/x64/1.10/julia-1.10.2-linux-x86_64.tar.gz
   
   # Extract the tarball
   tar -xvzf julia-1.10.2-linux-x86_64.tar.gz
   
   # Move to /opt
   sudo mv julia-1.10.2 /opt/
   
   # Create a symbolic link
   sudo ln -s /opt/julia-1.10.2/bin/julia /usr/local/bin/julia
</pre>~~~


4. **Using juliaup (Version Manager)**:
~~~<pre>bash

   curl -fsSL https://install.julialang.org | sh
</pre>~~~


## Verify Installation
Open a terminal and type:
~~~<pre>bash

julia --version
</pre>~~~


You should see the installed Julia version information.

## Set Up Julia Environment
Start Julia and install some basic packages:
~~~<pre>julia
# Launch Julia
julia

# Install common packages
using Pkg
Pkg.add(["IJulia", "Plots", "DataFrames"])
</pre>~~~
