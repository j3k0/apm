/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * @author 		Michael (https://github.com/marchbold)
 * @created		18/5/21
 */
package com.apm.client
{
	import com.apm.SemVer;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.airsdk.AIRSDKInstallCommand;
	import com.apm.client.commands.airsdk.AIRSDKListCommand;
	import com.apm.client.commands.airsdk.AIRSDKViewCommand;
	import com.apm.client.commands.general.ConfigCommand;
	import com.apm.client.commands.general.HelpCommand;
	import com.apm.client.commands.general.UpgradeCommand;
	import com.apm.client.commands.general.VersionCommand;
	import com.apm.client.commands.packages.BuildCommand;
	import com.apm.client.commands.packages.CreateCommand;
	import com.apm.client.commands.packages.InstallCommand;
	import com.apm.client.commands.packages.ListCommand;
	import com.apm.client.commands.packages.PublishCommand;
	import com.apm.client.commands.packages.SearchCommand;
	import com.apm.client.commands.packages.UninstallCommand;
	import com.apm.client.commands.packages.UpdateCommand;
	import com.apm.client.commands.packages.ViewCommand;
	import com.apm.client.commands.project.GenerateAppDescriptorCommand;
	import com.apm.client.commands.project.InitCommand;
	import com.apm.client.commands.project.ProjectConfigCommand;
	import com.apm.client.config.RunConfig;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.io.IO;
	import com.apm.client.io.IO_MacOS;
	import com.apm.client.io.IO_Windows;
	import com.apm.client.logging.Log;
	import com.apm.utils.FileUtils;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class APM extends EventDispatcher
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "APM";
		
		public static const CODE_OK:int = 0;
		public static const CODE_ERROR:int = 1;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _arguments:Array;
		private var _command:Command;
		
		private static var _config:RunConfig;
		public static function get config():RunConfig { return _config; }
		
		
		private static var _io:IO;
		public static function get io():IO
		{
			if (_io == null)
			{
				if (_config.isWindows) _io = new IO_Windows();
				else _io = new IO_MacOS();
			}
			return _io;
		}
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APM()
		{
			_instance = this;
			
			_config = new RunConfig();
			
			// general info commands
			addCommand( HelpCommand.NAME, HelpCommand );
			addCommand( VersionCommand.NAME, VersionCommand );
			addCommand( ConfigCommand.NAME, ConfigCommand );
			
			// project commands
			addCommand( InitCommand.NAME, InitCommand );
			addCommand( ProjectConfigCommand.NAME, ProjectConfigCommand );
			addCommand( GenerateAppDescriptorCommand.NAME, GenerateAppDescriptorCommand );
			
			// package commands
			addCommand( ListCommand.NAME, ListCommand );
			addCommand( SearchCommand.NAME, SearchCommand );
			addCommand( ViewCommand.NAME, ViewCommand );
			addCommand( InstallCommand.NAME, InstallCommand );
			addCommand( UninstallCommand.NAME, UninstallCommand );
			addCommand( UpdateCommand.NAME, UpdateCommand );
			
			// package creation commands
			addCommand( CreateCommand.NAME, CreateCommand );
			addCommand( BuildCommand.NAME, BuildCommand );
			addCommand( PublishCommand.NAME, PublishCommand );
			
			// air sdk commands
			addCommand( AIRSDKListCommand.NAME, AIRSDKListCommand );
			addCommand( AIRSDKViewCommand.NAME, AIRSDKViewCommand );
			addCommand( AIRSDKInstallCommand.NAME, AIRSDKInstallCommand );
			
		}
		
		
		public function main( arguments:Array ):void
		{
			try
			{
				_arguments = arguments;
				if (_arguments.length == 0)
				{
					usage();
					return exit( CODE_ERROR );
				}
				
				for (var i:int = 0; i < arguments.length; i++)
				{
					var arg:String = arguments[ i ];
					switch (arg)
					{
						case "-workingdir":
						{
							_config.workingDir = arguments[ ++i ];
							break;
						}
						
						case "-appdir":
						{
							_config.appDir = arguments[ ++i ];
							break;
						}
						
						case "-v":
						case "-version":
						{
							// PRINT VERSION
							io.writeLine( new SemVer( Consts.VERSION ).toString() );
							return exit( CODE_OK );
						}
						
						case "-loglevel":
						case "-l":
						{
							var level:String = arguments[ ++i ];
							switch (level)
							{
								case "v":
								case "verbose":
									Log.setLogLevel( Log.LEVEL_VERBOSE );
									break;
								
								case "d":
								case "debug":
									Log.setLogLevel( Log.LEVEL_DEBUG );
									break;
								
								default:
									Log.setLogLevel( Log.LEVEL_NORMAL );
									break;
							}
							break;
						}
						
						default:
						{
							// Check for command
							var CommandClass:Class = getCommand( arg );
							if (CommandClass == null && i + 1 < arguments.length)
							{
								CommandClass = getCommand( arg + "/" + arguments[ i + 1 ] )
								if (CommandClass != null) i++;
							}
							
							if (CommandClass != null)
							{
								_command = new CommandClass();
								if (i < arguments.length - 1)
								{
									_command.setParameters( arguments.slice( i + 1 ) );
								}
								i = arguments.length;
								break;
							}
							else
							{
								throw new Error( "Unknown command: " + arg );
							}
						}
					}
				}
				
			}
			catch (e:Error)
			{
				io.error( e );
				return exit( CODE_ERROR );
			}
			
			
			if (_command == null)
			{
				usage();
				return exit( CODE_ERROR );
			}
			
			try
			{
				// Working directory check
				try
				{
					new File( _config.workingDir );
				}
				catch (e:Error)
				{
					io.writeError( "ENV", "working directory not set correctly - check you haven't modified the start script" );
					return exit( CODE_ERROR );
				}
				
				
//				io.showSpinner( "loading environment ... " );
				_config.loadEnvironment( function ( success:Boolean, error:String = null ):void {
//					io.stopSpinner( success,"loaded environment", true );
					if (success)
					{
						processEnvironment();
						if (_command.requiresProject)
						{
							if (config.projectDefinition == null)
							{
								io.writeError( "project.apm", "No project file found, run 'apm init' first" );
								return exit( CODE_ERROR );
							}
						}
						
						if (_command.requiresNetwork && !_config.hasNetwork)
						{
							io.writeError( "NETWORK", "No active internet connection found" );
							return exit( CODE_ERROR );
						}
						
						_command.addEventListener( CommandEvent.COMPLETE, command_completeHandler );
						_command.addEventListener( CommandEvent.PRINT_USAGE, command_usageHandler );
						
						_command.execute();
					}
					else
					{
						io.writeError( "ENV", "failed to load environment: " + error );
						io.writeError( "ENV", "exiting..." );
						return exit( CODE_ERROR );
					}
				}, _command.requiresNetwork );
			}
			catch (e:Error)
			{
				io.error( e );
				return exit( CODE_ERROR );
			}
			
		}
		
		
		private function processEnvironment():void
		{
			if (_config.isMacOS)
			{
				if (_config.env.hasOwnProperty( "TERM" ))
				{
					// TODO:: improve this to detect if colour supported
					var term:String = _config.env[ "TERM" ];
					io.setColourSupported( term.indexOf( "color" ) >= 0 && !_config.user.disableTerminalControlSequences );
				}
				io.setTerminalControlSupported( !_config.user.disableTerminalControlSequences );
			}
			else if (_config.isWindows)
			{
				// TODO:: Improve how this is determined
				// Only enable for Windows Terminal (by looking for presence of WT_SESSION env variable)
				// other consoles (cmd/powershell) don't seem to have the new control sequences enabled by default
				// TODO: Potentially enable with an ANE? https://docs.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
				var enabled:Boolean = _config.env.hasOwnProperty( "WT_SESSION" );
				io.setColourSupported( enabled && !_config.user.disableTerminalControlSequences );
				io.setTerminalControlSupported( enabled && !_config.user.disableTerminalControlSequences );
			}
		}
		
		
		//
		//	COMMAND HANDLING
		//
		
		private var _apmCommandMap:Object;
		private var _apmCommandOrder:Array;
		
		
		private function addCommand( name:String, commandClass:Class ):void
		{
			if (_apmCommandMap == null) _apmCommandMap = {};
			if (_apmCommandOrder == null) _apmCommandOrder = [];
			
			_apmCommandMap[ name ] = commandClass;
			_apmCommandOrder.push( name );
		}
		
		
		private function getCommand( name:String ):Class
		{
			if (_apmCommandMap != null && _apmCommandMap[ name ] != null)
			{
				return _apmCommandMap[ name ];
			}
			return null;
		}
		
		
		private function command_completeHandler( event:CommandEvent ):void
		{
			exit( event.data );
		}
		
		private function command_usageHandler( event:CommandEvent ):void
		{
			usage( event.data );
		}
		
		
		//
		//	PROCESS HANDLING
		//
		
		
		public function usage( usageForCommand:String = null ):void
		{
			var command:Command;
			if (usageForCommand != null && _apmCommandMap.hasOwnProperty( usageForCommand ))
			{
				command = new _apmCommandMap[ usageForCommand ]();
				if (command != null)
				{
					io.writeLine( "apm " + command.name.replace( "/", " " ) );
					io.writeLine( "" );
					io.writeLine( command.usage );
					return;
				}
			}
			
			io.writeLine( "apm <command>" );
			io.writeLine( "" );
			io.writeLine( "Usage:" );
			io.writeLine( "" );
			
			for each (var commandName:String in _apmCommandOrder)
			{
				command = new _apmCommandMap[ commandName ]();
				var commandUsage:String = "apm " + commandName.replace( "/", " " ) + " ";
				while (commandUsage.length < 20) commandUsage += " ";
				commandUsage += command.description;
				io.writeLine( commandUsage );
			}
		}
		
		
		/**
		 * This is called on the end of the process
		 *
		 * @param returnCode	Success or failure of the command
		 */
		public function exit( returnCode:int = CODE_OK ):void
		{
			try
			{
				FileUtils.tmpDirectory.deleteDirectory( true );
			}
			catch (e:Error)
			{
			}
			
			NativeApplication.nativeApplication.exit( returnCode );
		}
		
		
		////////////////////////////////////////////////////////
		//	SIMPLE SINGLETON REFERENCE
		//
		
		private static var _instance:APM;
		public static function get instance():APM { return _instance; }
		
		
	}
}
