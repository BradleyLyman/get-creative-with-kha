var project = new Project('Hello Critter');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('support');
project.addAssets("../../assets");
project.addLibrary('zui');

resolve(project);