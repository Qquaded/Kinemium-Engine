declare shared: { [any]: any }
declare _VERSION: string

declare function wait(sec: number?): number
declare function typeof(value: any): string

declare kinemium: {
	version: number
}

declare function print(...: any): ()
declare function warn(...: any): ()
declare function error(message: any, level: number?): ()
declare function require(module: string | ModuleScript): any
declare function import(path: string): any
declare function include(object: Instance): ()