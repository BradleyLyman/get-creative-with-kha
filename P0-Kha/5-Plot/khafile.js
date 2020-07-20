var project = new Project('Plot');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('support');
project.addAssets("../../assets");

resolve(project);