# Spaak & De Lange (2019) Analysis code

This is the analysis code related to Spaak & De Lange (2019) paper "Hippocampal and prefrontal theta-band mechanisms underpin implicit spatial context learning".

## Getting started

### Dependencies

You'll need [FieldTrip](https://github.com/fieldtrip/fieldtrip) installed. The analysis for the paper was performed using commit [6414ea0](https://github.com/fieldtrip/fieldtrip/tree/6414ea000dcf5bba0ec43ce6487e3425e480b161), which you'll be able to obtain using

```
git clone git@github.com:fieldtrip/fieldtrip.git
cd fieldtrip
git checkout 6414ea000dcf5bba0ec43ce6487e3425e480b161
```

but it should work with any recent FieldTrip version.

If you want to run the switchpoint analyses, you'll need to have a scientific Python stack available, with [PyMC3](https://github.com/pymc-devs/pymc3) and its dependencies (notably, [Theano](https://github.com/Theano/Theano)) installed. (Version used for the paper for PyMC3 is [24730cc](https://github.com/Spaak/pymc3/tree/24730cc360852e27020f5b7c5ca07d3791ccb167), for Theano is [93e8180](https://github.com/Theano/Theano/tree/93e8180bf08b6fbe587b6f0ecc877ec90e6e1681).)

### Installing

* Clone the repo like normal.
* Get a copy of the (raw and processed) [data from the repository](https://hdl.handle.net/11633/aacstiks).
* Configure some paths in the code:
    * `matlab/run_all_analyses.m` - set `data_dir` to where you put the data from the repository.
    * `matlab/run_all_analyses.m` - set `results_dir` to where the results (figures and outputs of statistical tests) should appear. Will be created if it does not exist.
    * `python/analysis.py` - set `rootdir` to the same as Matlab's `data_dir` above.
    * `python/run_switchpoint_analyses.py` - set `working_dir` to the working directory of the Python script (usually the folder in which you cloned this repo + `/python`).

<!--

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo

## Running the tests

Explain how to run the automated tests for this system

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## Deployment

Add additional notes about how to deploy this on a live system

## Built With

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - The web framework used
* [Maven](https://maven.apache.org/) - Dependency Management
* [ROME](https://rometools.github.io/rome/) - Used to generate RSS Feeds

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Hat tip to anyone whose code was used
* Inspiration
* etc

-->