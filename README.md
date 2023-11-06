# SecureJoin protocols: usable security against active network attacks 

SecureJoin protocols are designed to 
counter MITM-attacks on Autocrypt E-Mail encryption
and are implemented and released by the [Delta Chat e-mail messenger](https://delta.chat).

This description is derived and refined from the the first two sections of
[CounterMitm](https://countermitm.readthedocs.io/en/latest/)
which were written by reseachers of NEXTLEAP, 
a 2016-2018 project on privacy and decentralized messaging,
funded through the EU Horizon 2020 programme. 


## Viewing SecureJoin Docs online

There are two public web pages: 

- https://securejoin.delta.chat

- https://securejoin.readthedocs.io/en/latest/


## Editing the documents 

If you want to do Pull Requests please note that we are using 
[Semantic Linefeeds](http://rhodesmill.org/brandon/2012/one-sentence-per-line/).
It means that the source code of this document should be 
broken down to a "one-line-per-phrase" format, 
as to make reviewing diffs easier. 

While this Readme uses Markdown syntax, the actual document
uses the richer RestructuredText format and in particular
the "Sphinx Document Generators".  You can probably get
around by just mimicking the syntax and "tricks" 
of the existing text.  You may also look at this 
[reStructuredText Primer](http://www.sphinx-doc.org/en/master/usage/restructuredtext/basics.html) for some basic editing advise.  


## Building the pdf

For the images we use inkscape to convert them from svg to pdf.

In order to create the documents you will need make, sphinx and inkscape installed
on your system. On a debian based system you can achieve this with

```sh
sudo apt install python-sphinx inkscape
```

From there on creating the pdf should be a matter of running

```sh
make images
make latexpdf
```

## Build Results

Once the build is completed there will be a CounterMitm.pdf file in the
build/latex directory. This contains the different approaches.

## Modifying the Images

The sources for the images are stored in .seq files.
We used https://bramp.github.io/js-sequence-diagrams/ to turn them into
svgs that live in the images directory.

We have not found a good way to automate this yet.
