#! /usr/bin/python

import argparse
import csv
import re
from os import path


def parseDuration(durationStr):
    
    parts = re.split('(\d+[,\.]?\d*)', durationStr)
    parts = [p for p in parts if p and len(p) > 0]
    
    if len(parts) < 2:
        return None
    try:
        if parts[1] == "ns":
            return float(parts[0]) * 10e-9 
        if parts[1] == "us":
            return float(parts[0]) * 10e-6
        if parts[1] == "ms":
            return float(parts[0]) * 10e-3
        if parts[1] == "s":
            return float(parts[0])
        if parts[1] == "min":
            return float(parts[0]) * 60
        if parts[1] == "h":
            return float(parts[0]) * 60 * 60
        if parts[1] == "d":
            return float(parts[0]) * 60 * 60 * 24
        
    except:
        return None

class ResultAnalyzer():
    def __init__(self, rowDelim = ' ', tagIdx = 0, tagDelim = '_', tagTimeIdx = 2, configIdx = 1, performanceIdx = 2, correction=1.0, correctionIdx=1):
        self.rowDelim = rowDelim
        self.tagIdx = tagIdx
        self.tagDelim = tagDelim
        self.tagTimeIdx = tagTimeIdx
        self.configIdx = configIdx
        self.performanceIdx = performanceIdx
        self.correction = correction
        self.correctionIdx = correctionIdx
        
    
    def analyzeFile(self, fileName):
        with open(fileName) as results:
            
            csvReader = csv.reader(results, delimiter=self.rowDelim)
            
            results = {}
            # read all rows
            for row in csvReader:
                parts = row[self.tagIdx].split(self.tagDelim);
                if len(parts) > self.tagTimeIdx:
                    # get time
                    time = parseDuration(parts[self.tagTimeIdx])
                
                # get performance value
                performanceValue = parseDuration(row[self.performanceIdx])
                
                if not performanceValue:
                    performanceValue = float(row[self.performanceIdx])
                
                if time and performanceValue:
                    if not row[self.configIdx] in results.keys():
                        results[row[self.configIdx]] = []
                    results[row[self.configIdx]].append([time, performanceValue])
            
        
        # apply correction factor
        for i in range(0, len(results[results.keys()[self.correctionIdx]])):
            results[results.keys()[self.correctionIdx]][i][1] *= self.correction
            
        return results
        
    def writeOutput(self, fileName, valuesList, headerNames):
        with open(fileName, 'w') as out:
            csvWriter = csv.writer(out, delimiter=self.rowDelim)
            # write header
            csvWriter.writerow(headerNames)
            
            for values in valuesList:
                csvWriter.writerow(values)
    
    def calcResults(self, values0, values1):
        result = []
        for val0, val1 in zip(values0, values1):
            result.append((val0[0], val0[1] - val1[1], val0[1]/val1[1]))
        
        # print average results
        print("The average difference is: %f" % (sum([val[1] for val in result]) / len(result)))
        print("The average ratio is: %f" % (sum([val[2] for val in result]) / len(result)))
        return result

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script for analyzing generated result files and convert times")
    parser.add_argument("fileName", help="filename of results file")
    parser.add_argument("-o", "--output-dir", dest="output", help="directory for generated output files")
    parser.add_argument("-g", "--generate-results", dest="results", action="store_true", help="flag for generating the results file (ratio and diff) only for 2 configurations")
    parser.add_argument("-i", "--performance-index", dest="index", type=int, help="Index of performance value within row of results file")
    parser.add_argument("-c", "--correction-factor", dest="correction", type=float, help="Correction value for the performance value of the second configuration")
    args = parser.parse_args()
    
    print("started")
    
    fileName = args.fileName
    #fileName= "realTimeResults.txt"
    
    parts = fileName.split('.')
    filePrefix = '.'.join(parts[:-1])
    fileExt = parts[-1]
    fileBasename = path.splitext(path.basename(fileName))[0]
    
    if args.correction:
        corr = args.correction
    else:
        corr = 1.0
    
    if args.index:
        analyzer = ResultAnalyzer(performanceIdx=args.index, correction=corr)
    else:
        analyzer = ResultAnalyzer(correction=corr)
    
    results = analyzer.analyzeFile(fileName)
    
    print("analyzed configurations:")
    for key in results.keys():
        print("   %s: %d entries" % (key, len(results[key])))
    
    for key in results.keys():
        if args.output:
            resultFile = args.output + path.sep + fileBasename + '.'  + key + '.' + fileExt
        else:
            resultFile = filePrefix + '.'  + key + '.' + fileExt
        analyzer.writeOutput(resultFile, results[key], ("Time", "PerformanceValue"))
        
    if args.results:
        if not len(results) == 2:
            raise "Results calculation is only possible for 2 configurations"
        
        print("generate results file")
        if args.output:
            resultFile = args.output + path.sep + fileBasename + '.results.' + fileExt
        else:
            resultFile = filePrefix + '.results.' + fileExt
        
        
        # calculate difference and ratio of performance values
        result = analyzer.calcResults(results.values()[0], results.values()[1])
        
        analyzer.writeOutput(resultFile, result, ("Time", "Difference", "Ratio"))
    
    print("finished")
    
    
    
    
    
    
