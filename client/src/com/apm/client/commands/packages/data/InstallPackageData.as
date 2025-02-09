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
 * @created		18/6/21
 */
package com.apm.client.commands.packages.data
{
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	
	import flash.html.script.Package;
	
	
	public class InstallPackageData
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallPackageData";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var packageVersion:PackageVersion;
		public var query:InstallQueryRequest;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallPackageData(
				packageVersion:PackageVersion,
				query:InstallQueryRequest )
		{
			this.packageVersion = packageVersion;
			this.query = query;
		}
		
		
		public function equals( b:InstallPackageData ):Boolean
		{
			if (packageVersion.equals( b.packageVersion ))
			{
				return true;
			}
			return false;
		}
		
	}
}
