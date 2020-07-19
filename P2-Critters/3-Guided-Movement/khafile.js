var project = new Project('Guided Movement');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('support');
project.addLibrary('zui');
project.addAssets("../../assets");

resolve(project);