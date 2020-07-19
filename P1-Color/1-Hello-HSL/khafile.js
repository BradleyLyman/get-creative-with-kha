var project = new Project('Hello HSL');

project.localLibraryPath = "../../libraries";

project.addSources('src');
project.addShaders('shaders');
project.addLibrary('support');

resolve(project);