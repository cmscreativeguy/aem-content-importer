package com.adobe.aem.importer;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;


@XmlRootElement(name = "config")
@XmlAccessorType(XmlAccessType.FIELD)
public class Config {
	
	@XmlElement(name = "transfomer")
	private String transformer;
	@XmlElement(name = "src")
	private String src;
	@XmlElement(name = "target")
	private String target;
	@XmlElement(name = "masterFile")
	private String masterFile;
	public String getTransformer() {
		return transformer;
	}
	public void setTransformer(String transformer) {
		this.transformer = transformer;
	}
	public String getSrc() {
		return src;
	}
	public void setSrc(String src) {
		this.src = src;
	}
	public String getTarget() {
		return target;
	}
	public void setTarget(String target) {
		this.target = target;
	}
	public String getMasterFile() {
		return masterFile;
	}
	public void setMasterFile(String masterFile) {
		this.masterFile = masterFile;
	}

}
