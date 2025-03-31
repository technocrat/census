# R Programming Language Setup

## macOS Installation

1. **Using Homebrew**:
~~~
<pre>
bash
   brew install r
</pre>
~~~
2. **Direct Download**:
   - Visit the CRAN website: https://cran.r-project.org/bin/macosx/
   - Download the latest R package (.pkg file)
   - Open the downloaded file and follow installation instructions

3. **Install RStudio (Optional)**:
   - Download from: https://www.rstudio.com/products/rstudio/download/
   - Open the .dmg file and drag RStudio to your Applications folder

## Ubuntu Installation

1. **Add the CRAN Repository**:
 ~~~
 <pre>bash
   # Update indices
   sudo apt update
   
   # Install required packages
   sudo apt install software-properties-common dirmngr
   
   # Add the signing key
   wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
   
   # Add the repository
   sudo add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
</pre>
~~~
2. **Install R**:
~~~
<pre>bash
   sudo apt update
   sudo apt install r-base r-base-dev
</pre>
~~~


## Verify Installation
Open a terminal and type:
~~~<pre>bash
R --version
</pre>~~~

You should see the installed R version information.

The Census package uses the classIntervals function from the classInt library to divide continuous arrays into discrete intervals for coloring maps. Other `R` libraries can be installed and loaded using the R.Setup submodule, as described in the documentation. (In preparation—link to be provided)