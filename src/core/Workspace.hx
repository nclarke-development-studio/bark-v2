package core;

import data.SceneData;

class Workspace {
    public var name:String;
    public var scenes:Map<String, SceneData> = [];
    public var activeSceneId:String;

    public function new(?n:String) {
        name = n;
    }

    public function getActiveScene():SceneData {
        return scenes.get(activeSceneId);
    }

    public function addScene(scene:SceneData) {
        scenes.set(scene.id, scene);
        if (activeSceneId == null)
            activeSceneId = scene.id;
    }

    public function removeScene(id:String) {
        scenes.remove(id);
        if (activeSceneId == id)
            activeSceneId = scenes.keys().next();
    }
}
