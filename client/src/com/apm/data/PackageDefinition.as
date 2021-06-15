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
 * @created		9/6/21
 */
package com.apm.data
{
	import com.apm.SemVer;
	
	
	public class PackageDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var name:String = "";
		public var description:String = "";
		public var identifier:String = "";
		public var type:String = "ane";
		public var versions:Vector.<PackageVersionDefinition>;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinition()
		{
			versions = new Vector.<PackageVersionDefinition>();
		}
		
		
		public function toString():String
		{
			return identifier +
					"@" + (versions.length > 0 ? versions[ 0 ].toString() : "x.x.x") +
					"   " + description;
		}
		
		
		public function fromObject( data:Object ):PackageDefinition
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "name" )) this.name = data[ "name" ];
				if (data.hasOwnProperty( "description" )) this.description = data[ "description" ];
				if (data.hasOwnProperty( "identifier" )) this.identifier = data[ "identifier" ];
				if (data.hasOwnProperty( "type" )) this.type = data[ "type" ];
				if (data.hasOwnProperty( "versions" ))
				{
					for each (var versionObject:Object in data.versions)
					{
						versions.push( new PackageVersionDefinition().fromObject( versionObject ) );
					}
				}
			}
			return this;
		}
		
	}
	
}
