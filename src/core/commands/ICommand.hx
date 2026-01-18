package core.commands;

interface ICommand {
    function undo():Void;
    function execute():Void;
}