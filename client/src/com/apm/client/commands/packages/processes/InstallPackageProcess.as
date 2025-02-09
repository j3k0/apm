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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.analytics.Analytics;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process downloads and extracts an AIR package
	 */
	public class InstallPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _installData:InstallPackageData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallPackageProcess( installData:InstallPackageData )
		{
			super();
			_installData = installData;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.writeLine( "Installing package : " + _installData.packageVersion.packageDef.toString() );
			
			var packageDir:File = PackageFileUtils.cacheDirForPackage( APM.config.packagesDir, _installData.packageVersion.packageDef.identifier );
			var packageFile:File = PackageFileUtils.fileForPackage( APM.config.packagesDir, _installData.packageVersion );
			
			var queue:ProcessQueue = new ProcessQueue();
			
			queue.addProcess( new DownloadPackageProcess( _installData.packageVersion ) );
			queue.addProcess( new ExtractZipProcess( packageFile, packageDir ) );
			
			queue.start( function ():void {
							 if (_installData.query.isNew)
							 {
								 Analytics.instance.install(
										 _installData.packageVersion.packageDef.identifier,
										 _installData.packageVersion.version.toString(),
										 complete );
							 }
							 else
							 {
								 complete();
							 }
				
						 },
						 function ( error:String ):void {
							 APM.io.writeError( "ERROR", "Failed to install package : " + _installData.packageVersion.packageDef.toString() );
							 failure( error );
						 } );
			
		}
		
		
		override protected function complete( data:Object=null ):void
		{
			APM.io.writeLine( "Installed package : " + _installData.packageVersion.packageDef.toString() );
			super.complete();
		}
		
		
	}
	
}
