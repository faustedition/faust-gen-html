xquery version "3.1";

module namespace config = "http://www.faustedition.net/search/config";

declare variable $config:xmlpath := request:get-attribute('xmlpath');
declare variable $config:data-path := if ($config:xmlpath) then $config:xmlpath else '/db/apps/faust-dev/data';
declare variable $config:data := collection($config:data-path);
declare variable $config:transcripts := collection($config:data-path || "/textTranscript");
declare variable $config:metadata := collection($config:data-path || "/meta");

declare variable $config:lucene-options := <options xmlns="">
                                        <default-operator>and</default-operator>
                                        <phrase-slop>1</phrase-slop>
                                        <leading-wildcard>no</leading-wildcard>
                                        <filter-rewrite>yes</filter-rewrite>
                                    </options>;
