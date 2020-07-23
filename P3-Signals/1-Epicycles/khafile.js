var project = new Project('Epicycles');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('support');

resolve(project);