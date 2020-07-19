var project = new Project('zui');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('zui');
project.addAssets("../../assets")

resolve(project);